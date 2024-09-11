class_name FightNodeGD extends MapNodeGD

var level_id: int
var spawn_ids: Array = []

#region Save / Load / Init
func onFofInit(area: AreaGD) -> void:
	var levels: Array = Helper.getFofInfoArray(area.info.level_script)
	levels = levels.filter(func(x: LevelInfo): \
		return map_location.progress >= x.progress_min and map_location.progress <= x.progress_max)
		
	var level: LevelInfo = levels.pick_random()
	level_id = level.id

	for i in range(level.enemy_max_spawn_amount):
		var value: int = area.card_ids.pick_random() if i < level.enemy_spawn_amount else 0
		spawn_ids.append(value)
		
	spawn_ids.shuffle()
	
func onSave() -> SavedDataMapNode:
	return SavedDataMapNodeFight.new(info.id, map_location, links, level_id, spawn_ids)
	
func onLoadData(data: SavedData) -> void:
	super(data)
	level_id = data.level_id
	spawn_ids = data.spawn_ids
#endregion

#region Base Functions
func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and HoverUI != null: HoverUI.setMouseCenter(get_viewport().get_mouse_position())
#endregion

#region Hovering
var HoverUI: Control
func onMouseHovered(state: bool) -> void:
	if !state and HoverUI != null: HoverUI.queue_free()
	else: HoverUI = load(info.FIGHT_NODE_HOVER_UI).instantiate(); HoverUI.setMouseCenter(get_viewport().get_mouse_position())
	super(state)
#endregion
