class_name SavedDataGameObject extends SavedData

@export var variation: int
@export var tile_rotation: int
@export var coords: Vector4i

func _init(_id: int = 0, _variation: int = 0, _coords := Vector4.ZERO, _tile_rotation: int = 0) -> void:
	super(_id)
	variation = _variation
	coords = _coords
	tile_rotation = _tile_rotation

func onLoadModel(parent: Node3D) -> GameObjectGD:
	var model = Node3D.new()
	model.script = call("getBaseInfo").gdscript
	model.onLoad(self, parent)
	return model
