class_name SavedDataMapNode extends SavedData

@export var map_location: MapLocation
@export var links: Array

func _init(_id: int = 0, _map_location: MapLocation = null, _links: Array = []) -> void:
	super(_id)
	map_location = _map_location
	links = _links
	
func getInfoType() -> GDScript: return MapNodeInfo
