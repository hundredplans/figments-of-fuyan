class_name SavedDataFight extends SavedDataMapNode

@export var level_info: LevelInfo
@export var enemy_spawns: Array

func _init(_id: int = 0, _first_init: bool = false, _public_id: int = 0, _map_location: MapLocation = null, _links: Array = [], _is_entered: bool = false, _is_finished: bool = false,\
	_rotation_y: float = 0, _level_info: LevelInfo = null, _enemy_spawns: Array = []) -> void:
	super(_id, _first_init, _public_id, _map_location, _links, _is_entered, _is_finished, _rotation_y)
	level_info = _level_info
	enemy_spawns = _enemy_spawns
	
