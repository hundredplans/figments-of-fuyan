extends Resource

@export var mini_tool_info: Array[ToolInfoGD]
@export var models: Array[PackedScene]
# Stick, Halfeaten Coc, Palmleaf, Sand Larva, Bag of Sand

func getIObjectID(mini_tool_id: int) -> int:
	return mini_tool_id + 8

func getToolID(iobj_id: int) -> int:
	return iobj_id - 8

func onCreateEquipModelAnimation(Tile: TileGD, model: Node3D, delay: float, callable: Callable = Callable()) -> void:
	var shorter_delay: float = (delay - 0.2) / 3.0
	var tween := model.create_tween()
	tween.tween_property(model, "position:y", Tile.Unit.height.stat + 0.3, shorter_delay)
	tween.tween_property(model, "rotation:y", TAU, shorter_delay).as_relative()
	tween.tween_property(model, "scale", Vector3(0.01, 0.01, 0.01), shorter_delay)
	tween.finished.connect(callable)
