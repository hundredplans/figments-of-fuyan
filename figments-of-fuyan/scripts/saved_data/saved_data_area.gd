class_name SavedDataArea extends SavedData

@export var overworld_level_id: int
@export var map_location: MapLocation
@export var map_nodes_data: Array[SavedDataMapNode]

func _init(_id: int = 0, _overworld_level_id: int = 0, _map_location: MapLocation = null, _map_nodes_data: Array[SavedDataMapNode] = []) -> void:
	super(_id)
	overworld_level_id = _overworld_level_id
	map_location = _map_location
	map_nodes_data = _map_nodes_data

func getInfoType() -> GDScript: return AreaInfo
