class_name SavedDataArea extends SavedData

@export var level_data: SavedDataLevel
@export var map_nodes_data: Array

func _init(_id: int = 0, _first_init: bool = false, _public_id: int = 0, _map_nodes_data: Array = [],\
	_level_data: SavedDataLevel = null) -> void:
	super(_id, _first_init, _public_id)
	map_nodes_data = _map_nodes_data
	level_data = _level_data

func getInfoType() -> GDScript: return AreaInfo

func getEnteredMapLocation() -> MapLocation:
	for data in map_nodes_data:
		if data.is_entered: return data.map_location
	return null

func getEnteredMapLocationProgress() -> int:
	for data in map_nodes_data:
		if data.is_entered: return data.map_location.progress
	return 0
