class_name FightNodeGD extends MapNodeGD

var enemy_spawns: Array
var level_info: LevelInfo
#region Save / Load / Init
func onFofInit() -> void:
	var area: AreaGD = get_tree().get_nodes_in_group("AreasGD")[0]
	var levels: Array = Helper.getFofInfoArray(area.info.level_script)
	levels = levels.filter(func(x: LevelInfo): \
		return map_location.progress >= x.progress_min and map_location.progress <= x.progress_max)
		
	level_info = levels.pick_random()
	var empty_spawn_coords: Array = level_info.data\
		.filter(func(x: SavedDataTileObject): return x is SavedDataSpawn and x.spawn_id == 0 and x.variation == 1)\
		.map(func(x: SavedDataSpawn): return x.coords)
		
	var enemy_spawn_amount: int = max(randi_range(level_info.enemy_min_spawn_amount, level_info.enemy_max_spawn_amount), empty_spawn_coords.size() - 1)
	for i in range(enemy_spawn_amount):
		enemy_spawns.append(area.getRandomEnemySpawn(empty_spawn_coords[i], map_location.progress))
	enemy_spawns.shuffle()
	
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
	if !state and HoverUI != null: HoverUI.queue_free()
	else:
		HoverUI = load(info.FIGHT_NODE_HOVER_UI).instantiate()
		HoverUI.setMouseCenter(get_viewport().get_mouse_position())
	super(state)
#endregion

#region Loading Level
func onEntered() -> void:
	super()
	var new_level_data: SavedDataLevel = level_info.saved_data.new(level_info.id, true, 0, level_info.data.duplicate(), enemy_spawns)
	new_level_data.is_elite = false
	is_finished = true
	
	load_level.emit(new_level_data)
#endregion
