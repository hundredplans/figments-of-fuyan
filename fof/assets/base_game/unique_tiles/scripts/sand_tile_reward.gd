extends UniqueTileGD

var palm_mini_tool_info: Resource = preload("res://assets/base_game/unique_tiles/extras/palm_mini_tool_info.tres")
@export var models: Array
@export var delay: float = 2

var has_sprung: bool = false
func onReady() -> void:
	var model: Node3D = Tile.types[0].model.get_node("CoconutPile")
	model.visible = false
	
func onTrigger(_Unit: UnitGD, trigger: int, args: TriggerInfoGD) -> void:
	if trigger == TriggerGD.END_TURN_GLOBAL and Tile.Unit != null and !has_sprung:
		var Unit: UnitGD = Tile.Unit
		has_sprung = true
		ActionManager.onAddAction(DelayActionGD.new(onDelay.bind(Unit), Unit.isVis(), DelayGD.new(delay)), ActionManager.PUSH)
		
func onDelay(Unit: UnitGD) -> void:
	ActionManager.onInterruptMovement()
	var index: int = randi_range(0, palm_mini_tool_info.mini_tool_info.size() - 1)
	var packed_scene: PackedScene = palm_mini_tool_info.models[index]
	var model: Node3D = packed_scene.instantiate()
	model.rotation_degrees.y = randi_range(0, 360)
	Tile.Effects.add_child(model)
	
	var shorter_delay: float = (delay - 0.2) / 3.0
	var tween := create_tween()
	tween.tween_property(model, "position:y", Tile.Unit.height.stat + 0.3, shorter_delay)
	tween.tween_property(model, "rotation:y", TAU, shorter_delay).as_relative()
	tween.tween_property(model, "scale", Vector3(0.01, 0.01, 0.01), shorter_delay)
	
	await tween.finished
	model.queue_free()
	Tools.onEquipTool(Unit, palm_mini_tool_info.mini_tool_info[index].id)
	
