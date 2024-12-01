class_name MapLink extends Resource

signal update_finished

@export var map_location: MapLocation
@export var is_holy: bool
@export var is_finished: bool
@export var is_selected: bool

func _init(_map_location: MapLocation = null, _is_holy: bool = false, _is_finished: bool = false, _is_selected: bool = false) -> void:
	map_location = _map_location
	is_holy = _is_holy
	is_finished = _is_finished
	is_selected = _is_selected

func setIsFinished(_is_finished: bool) -> void:
	is_finished = _is_finished
	update_finished.emit(self, is_finished)
