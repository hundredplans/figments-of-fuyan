class_name MapLocation extends Resource

@export var progress: int = -1
@export var lane: int
@export var area: int
@export var position: Vector3

func isAfterMiniboss() -> bool:
	return progress >= 5

func _init(_progress: int = 0, _lane: int = 0, _area: int = 0, _position := Vector3.ZERO) -> void:
	progress = _progress
	lane = _lane
	area = _area
	position = _position
