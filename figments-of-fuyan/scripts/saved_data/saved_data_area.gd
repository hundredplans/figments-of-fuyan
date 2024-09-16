class_name SavedDataArea extends SavedData

@export var overworld_level_id: int
@export var level_data: SavedDataLevel
@export var map_nodes_data: Array[SavedDataMapNode]

func _init(_id: int = 0, _first_init: bool = false, _overworld_level_id: int = 0, _map_nodes_data: Array[SavedDataMapNode] = [],\
	_level_data: SavedDataLevel = null) -> void:
	super(_id, _first_init)
	overworld_level_id = _overworld_level_id
	map_nodes_data = _map_nodes_data
	level_data = _level_data

func getInfoType() -> GDScript: return AreaInfo

func getEnteredMapLocation() -> MapLocation:
	for data in map_nodes_data:
		if data.is_entered: return data.map_location
	return null
