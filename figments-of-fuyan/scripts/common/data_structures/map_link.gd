class_name MapLink extends Resource

@export var map_location: MapLocation
@export var is_holy: bool

func _init(_map_location: MapLocation = null, _is_holy: bool = false) -> void:
	map_location = _map_location
	is_holy = _is_holy
