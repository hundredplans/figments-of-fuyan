class_name SavedDataMapNodeFight extends SavedDataMapNode

@export var level_id: int
@export var spawn_ids: Array

func _init(_id: int = 0, _map_location: MapLocation = null, _links: Array = [], _level_id: int = 0, _spawn_ids: Array = []) -> void:
	super(_id, _map_location, _links)
	level_id = _level_id
	spawn_ids = _spawn_ids
