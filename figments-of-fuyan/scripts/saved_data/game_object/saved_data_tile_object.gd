class_name SavedDataTileObject extends SavedDataGameObject

@export var variation: int

func _init(_id: int = 0, _first_init: bool = false, _coords := Vector4i.ZERO,\
 _tile_rotation: int = 0, _variation: int = 0) -> void:
	super(_id, _first_init, _coords, _tile_rotation)
	variation = _variation

func getInfoType() -> GDScript: return TileObjectInfo
