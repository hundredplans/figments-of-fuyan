class_name SavedDataObject extends SavedDataTileObject

@export var rotation: float
@export var position: Vector3
@export var height: int
@export var occupied_coords: Array

func _init(_id: int = 0, _first_init: bool = false, _coords := Vector4i.ZERO, _tile_rotation: int = 0,\
	_level_visible: bool = true, _is_revealed: bool = false, _variation: int = 0, _rotation: float = 0, _position := Vector3.ZERO, _height: int = 0, _occupied_coords: Array = []) -> void:
	super(_id, _first_init, _coords, _tile_rotation, _level_visible, _variation, _is_revealed)
	rotation = _rotation
	position = _position
	height = _height
	occupied_coords = _occupied_coords

func getInfoType() -> GDScript: return ObjectInfo
	
