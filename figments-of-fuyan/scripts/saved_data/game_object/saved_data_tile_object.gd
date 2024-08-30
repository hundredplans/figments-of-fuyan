class_name SavedDataTileObject extends SavedDataGameObject

@export var variation: int

func _init(_id: int = 0, _coords := Vector4i.ZERO,\
 _tile_rotation: int = 0, _variation: int = 0) -> void:
	super(_id, _coords, _tile_rotation)
	variation = _variation

func getInfoType() -> GDScript: return TileObjectInfo
