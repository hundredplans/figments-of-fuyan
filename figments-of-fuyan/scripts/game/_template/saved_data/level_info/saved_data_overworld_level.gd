class_name SavedDataOverworldLevel extends SavedDataLevel

@export var map_location: MapLocation
@export var map_nodes_data: Array[SavedDataMapNode]

func _init(_id: int = 0, _map_location: MapLocation = null, _map_nodes_data: Array[SavedDataMapNode] = []) -> void:
	super(_id)
	map_location = _map_location
	map_nodes_data = _map_nodes_data

func getBaseInfo() -> LevelInfoGD: return Helper.getResourcesRecursiveID(OverworldLevelInfoGD, id)
