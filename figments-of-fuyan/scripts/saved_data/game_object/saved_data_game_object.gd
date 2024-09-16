class_name SavedDataGameObject extends SavedData

@export var tile_rotation: int
@export var coords: Vector4i

func _init(_id: int = 0, _first_init: bool = false, _coords := Vector4.ZERO, _tile_rotation: int = 0) -> void:
	super(_id, _first_init)
	coords = _coords
	tile_rotation = _tile_rotation

func getInfoType() -> GDScript: return GameObjectInfo
