class_name FightNodeGD extends MapNodeGD

var spawn_ids: Array = []
var level_info: LevelInfo
#region Save / Load / Init
func onFofInit() -> void:
	var area: AreaGD = get_tree().get_nodes_in_group("AreasGD")[0]
	var levels: Array = Helper.getFofInfoArray(area.info.level_script)
	levels = levels.filter(func(x: LevelInfo): \
		return map_location.progress >= x.progress_min and map_location.progress <= x.progress_max)
		
	level_info = levels.pick_random()

	for i in range(level_info.enemy_max_spawn_amount):
		var value: int = area.card_ids.pick_random() if i < level_info.enemy_spawn_amount else 0
		spawn_ids.append(value)
		
	spawn_ids.shuffle()
	
func onSave() -> SavedDataMapNode:
	return SavedDataMapNodeFight.new(info.id, false, map_location, links, is_entered, is_finished, rotation.y, level_info, spawn_ids)
	
func onLoadData(data: SavedData) -> void:
	super(data)
	level_info = data.level_info
	spawn_ids = data.spawn_ids
#endregion

#region Base Functions
func _input(event: InputEvent) -> void:
	super(event)
	if event is InputEventMouseMotion and HoverUI != null: HoverUI.setMouseCenter(get_viewport().get_mouse_position())
#endregion

#region Hovering
func onMouseHovered(state: bool) -> void:
	if !state and HoverUI != null: HoverUI.queue_free()
	else: HoverUI = load(info.FIGHT_NODE_HOVER_UI).instantiate(); HoverUI.setMouseCenter(get_viewport().get_mouse_position())
	super(state)
#endregion

#region Loading Level
func onLoadEntered() -> bool:
	load_level.emit(LevelInfo.getDataFromType(level_info.get_script()).new(level_info.id, true, level_info.timeout))
	return true
#endregion
