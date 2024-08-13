class_name ObjectDataGD
extends TileObjectData

@export var position: Vector3
@export var height: int

func getDuplicate() -> TileObjectData:
	return ObjectDataGD.new(id, position, variation, rotation)

func _init(_id: int = 0, _position := Vector3.ZERO, _variation: int = 0, _rotation: float = 0) -> void:
	id = _id
	position = _position
	variation = _variation
	rotation = _rotation

func onLoad(parent: Node3D = null, info: TileObjectInfo = Helper.getResourcesRecursiveID(INFO_PATH, ObjectInfo, id)) -> ObjectGD:
	var model: ObjectGD = info.getModel(self)
	model.setRotation(rotation)
	model.setMapPosition(position)
	parent.add_child(model)
	return model
