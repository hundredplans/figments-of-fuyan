class_name SavedDataMapNode extends SavedData

@export var is_finished: bool
@export var is_entered: bool
@export var map_location: MapLocation
@export var links: Array
@export var rotation_y: float

func _init(_id: int = 0, _first_init: bool = false, _map_location: MapLocation = null, _links: Array = [],\
_is_entered: bool = false, _is_finished: bool = false, _rotation_y: float = 0) -> void:
	super(_id, _first_init)
	map_location = _map_location
	links = _links
	is_entered = _is_entered
	is_finished = _is_finished
	rotation_y = _rotation_y
	
func getInfoType() -> GDScript: return MapNodeInfo
