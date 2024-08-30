class_name SavedDataObject extends SavedDataTileObject

@export var rotation: float
@export var position: Vector3
@export var height: int

func _init(_id: int = 0, _coords := Vector4i.ZERO, _tile_rotation: int = 0,\
	_variation: int = 0, _rotation: float = 0, _position := Vector3.ZERO, _height: int = 0) -> void:
	super(_id, _coords, _tile_rotation, _variation)
	rotation = _rotation
	position = _position
	height = _height

func getInfoType() -> GDScript: return ObjectInfo
	
