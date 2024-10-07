class_name SavedDataGameObject extends SavedData

@export var tile_rotation: int
@export var level_visible: bool
@export var coords: Vector4i
@export var is_revealed: bool

func _init(_id: int = 0, _first_init: bool = false, _coords := Vector4.ZERO, _tile_rotation: int = 0, _level_visible: bool = true, _is_revealed: bool = false) -> void:
	super(_id, _first_init)
	coords = _coords
	tile_rotation = _tile_rotation
	level_visible = _level_visible
	is_revealed = _is_revealed

func getInfoType() -> GDScript: return GameObjectInfo
