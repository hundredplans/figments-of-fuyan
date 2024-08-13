class_name TileDataGD
extends TileObjectData

@export var coords: Vector4i
# The bottom height for Tile Fill
@export var tile_fill: bool = false

func getDuplicate() -> TileObjectData:
	return TileDataGD.new(id, coords, variation, rotation)

func _init(_id: int = 0, _coords := Vector4i.ZERO, _variation: int = 0, _rotation: float = 0) -> void:
	id = _id
	coords = _coords
	variation = _variation
	rotation = _rotation

func onLoad(parent: Node3D = null, info: TileObjectInfo = Helper.getResourcesRecursiveID(INFO_PATH, TileInfo, id)) -> TileGD:
	var model: TileGD = info.getModel(self)
	model.setRotation(rotation)
	model.setCoords(coords)
	parent.add_child(model)
	model.onCreateTileFill(tile_fill)
	return model
