class_name SavedDataTileObject extends SavedDataGameObject

@export var variation: int

func _init(_id: int = 0, _first_init: bool = false, _coords := Vector4i.ZERO,\
 _tile_rotation: int = 0, _level_visible: bool = true, _is_revealed: bool = false, _variation: int = 0) -> void:
	super(_id, _first_init, _coords, _tile_rotation, _level_visible, _is_revealed)
	variation = _variation

func getInfoType() -> GDScript: return TileObjectInfo
