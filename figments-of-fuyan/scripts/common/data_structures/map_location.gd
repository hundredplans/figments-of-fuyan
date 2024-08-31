class_name MapLocation extends Resource

@export var progress: int = -1
@export var lane: int
@export var area: int
@export var location_finished: bool

func isAfterMiniboss() -> bool:
	return progress > 5 or (progress == 5 and location_finished)

func _init(_progress: int = 0, _lane: int = 0, _area: int = 0, _location_finished: bool = false) -> void:
	progress = _progress
	lane = _lane
	area = _area
	location_finished = _location_finished
