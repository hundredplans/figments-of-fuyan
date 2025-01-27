class_name FightNodeGD extends MapNodeGD

var enemy_spawns: Array = []
var level_info: LevelInfo
const FORCE_LEVEL_ID: int = 0

#region Save / Load / Init
func onFofInit() -> void:
	super()
	
	if self is EliteFightNodeGD:
		return
	
	setLevelInfo()
	var empty_spawn_coords: Array = getEmptySpawnCoords(level_info)
	var enemy_spawn_amount: int = min(randi_range(level_info.enemy_min_spawn_amount, level_info.enemy_max_spawn_amount), empty_spawn_coords.size())
	var budget: int = getBudget()
	
	enemy_spawns = Game.area.setEnemySpawnsFromBudget(budget, enemy_spawn_amount, empty_spawn_coords, map_location.progress, false)
	
func onSave() -> SavedDataMapNode:
	return SavedDataFight.new(info.id, false, public_id, map_location, links, is_entered, is_finished, rotation.y, level_info, enemy_spawns)
	
func onLoadData(data: SavedData) -> void:
	super(data)
	level_info = data.level_info
	enemy_spawns = data.enemy_spawns
#endregion

#region Base Functions
func _input(event: InputEvent) -> void:
	super(event)
	if event is InputEventMouseMotion and HoverUI != null: HoverUI.setMouseCenter(get_viewport().get_mouse_position())
#endregion

#region Hovering
func onMouseHovered(state: bool) -> void:
	if is_queued_for_deletion(): return
	if !state and HoverUI != null: HoverUI.queue_free()
	else:
		HoverUI = load(info.FIGHT_NODE_HOVER_UI).instantiate()
		HoverUI.setMouseCenter(get_viewport().get_mouse_position())
	super(state)
#endregion

#region Loading Level
func onEntered() -> void:
	super()
	onCreateScreen()
	
func onFinished() -> void:
	super()
	if self is EliteFightNodeGD: return
	var new_level_data: SavedDataLevel = level_info.saved_data.new(level_info.id, true, 0, level_info.data.duplicate(), enemy_spawns)
	load_level.emit(new_level_data)
#endregion

#region Level Gen
func getBudget() -> int:
	return Game.area.getBudget(map_location.progress, level_info.enemy_budget_offset, Game.isDivinus() and !isHoly())
	
func setLevelInfo() -> void:
	var levels: Array = Helper.getFofInfoArray(Game.area.info.base_level_script)
	
	if FORCE_LEVEL_ID == 0:
		levels = levels.filter(func(x: LevelInfo): \
			return map_location.progress >= x.progress_min and map_location.progress <= x.progress_max)
		level_info = levels.pick_random()
	else:
		level_info = Helper.getFofInfoID(LevelInfo, FORCE_LEVEL_ID)
		
	
	
func getEmptySpawnCoords(level_info: LevelInfo) -> Array:
	var empty_spawn_coords: Array = level_info.getEmptySpawnCoords()
	empty_spawn_coords.shuffle()
	return empty_spawn_coords
#endregion
