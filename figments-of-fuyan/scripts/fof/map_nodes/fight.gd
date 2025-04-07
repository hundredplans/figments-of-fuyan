class_name FightNodeGD extends MapNodeGD

var spawn_group: String
var enemy_cards: Array # Array[SavedDataCard]
var level_info: LevelInfo

#region Save / Load / Init
func onFofInit() -> void:
	super()
	setLevelInfo()
	
	spawn_group = level_info.getRandomSpawnGroup()
	var enemy_spawns: Array = level_info.getEnemySpawnsInGroup(spawn_group) # Array[SavedDataSpawn]
	enemy_spawns.shuffle()
	
	var budget: int = getBudget()
	
	enemy_cards = Game.area.setEnemySpawnsFromBudget(budget, level_info.enemy_min_spawn_amount, level_info.enemy_max_spawn_amount, enemy_spawns, map_location.progress, false)
	
func onSave() -> SavedDataMapNode:
	return SavedDataFight.new(info.id, false, public_id, map_location, links, is_entered, is_finished, rotation.y, ability_save, level_info, spawn_group, enemy_cards)
	
func onLoadData(data: SavedData) -> void:
	super(data)
	level_info = data.level_info
	enemy_cards = data.enemy_cards
	spawn_group = data.spawn_group
	add_to_group("FightMapNodesGD")
#endregion

#region Hovering
func onMouseHovered(state: bool) -> void:
	super(state)
	
func onUpdateHovered() -> void:
	if is_queued_for_deletion(): return
	var state: bool = getHoveredState()
	if state:
		if HoverUI != null: HoverUI.queue_free()
		HoverUI = load(getHoverUIPath()).instantiate()
	super()
	
func getHoverUIPath() -> String:
	return info.FIGHT_NODE_HOVER_UI
#endregion

#region Loading Level
func onEntered() -> void:
	super()
	onCreateScreen()
	
func onFinished() -> void:
	super()
	if self is EliteFightNodeGD or self is MinibossFightNodeGD or self is BossFightNodeGD: return
	var new_level_data: SavedDataLevel = level_info.saved_data.new(level_info.id, true, 0, level_info.data.duplicate())
	new_level_data.enemy_cards = enemy_cards
	new_level_data.spawn_group = spawn_group
	new_level_data.fight_type = Game.FightTypes.REGULAR
	
	load_level.emit(new_level_data)
#endregion

#region Level Gen
func getBudget() -> int:
	return Game.area.getBudget(map_location.progress, level_info.enemy_budget_offset)
	
func setLevelInfo() -> void:
	if Helper.admin_datastore.force_level_spawn_id > 0 and map_location.progress == 1:
		level_info = Helper.getFofInfoID(LevelInfo, Helper.admin_datastore.force_level_spawn_id)
	else:
		var existing_level_ids: Array = get_tree().get_nodes_in_group("FightMapNodesGD")\
			.filter(func(x: MapNodeGD): return x.map_location.progress == map_location.progress and x != self)\
			.map(func(y: MapNodeGD): return y.level_info.id if y.level_info != null else 0)\
			.filter(func(z: int): return z != 0)
			
		var levels: Array = Helper.getFofInfoArray(Game.area.info.base_level_script)
		levels = levels.filter(func(x: LevelInfo): \
			return map_location.progress >= x.progress_min and map_location.progress <= x.progress_max)
		
		if levels.size() > existing_level_ids.size():
			levels = levels.filter(func(x: LevelInfo): return x.id not in existing_level_ids)
			
		level_info = levels.pick_random()
#endregion
