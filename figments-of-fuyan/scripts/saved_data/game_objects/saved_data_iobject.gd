class_name SavedDataIObject extends SavedDataObject

@export var active_effects: Array
@export var ability_save: Dictionary

func _init(_id: int = 0, _first_init: bool = false, _public_id: int = 0, _coords := Vector4i.ZERO, _tile_rotation: int = 0,\
	_vision_datastore := VisionDatastore.new(), _variation: int = 0, _rotation: float = 0, _position := Vector3.ZERO,\
	_height: int = 0, _occupied_coords: Array = [], _groups: Array = [], _active_effects: Array = [], _ability_save: Dictionary = {}) -> void:
	super(_id, _first_init, _public_id, _coords, _tile_rotation, _vision_datastore, _variation, _rotation, _position, _height, _occupied_coords, _groups)
	active_effects = _active_effects
	ability_save = _ability_save

func getInfoType() -> GDScript: return ObjectInfo
