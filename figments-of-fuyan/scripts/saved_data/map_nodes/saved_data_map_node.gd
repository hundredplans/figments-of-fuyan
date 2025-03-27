class_name SavedDataMapNode extends SavedData

@export var is_finished: bool
@export var is_entered: bool
@export var map_location: MapLocation
@export var links: Array
@export var rotation_y: float
@export var ability_save: Dictionary

func _init(_id: int = 0, _first_init: bool = false, _public_id: int = 0, _map_location: MapLocation = null, _links: Array = [],\
_is_entered: bool = false, _is_finished: bool = false, _rotation_y: float = 0, _ability_save: Dictionary = {}) -> void:
	super(_id, _first_init, _public_id)
	map_location = _map_location
	links = _links
	is_entered = _is_entered
	is_finished = _is_finished
	rotation_y = _rotation_y
	ability_save = _ability_save
	
func getInfoType() -> GDScript: return MapNodeInfo

func isHoly() -> bool:
	return links.any(func(x: MapLink): return x.is_holy)
	
