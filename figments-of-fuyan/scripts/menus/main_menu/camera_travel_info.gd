class_name CameraTravelInfo extends Resource

@export var start: CameraItem
@export var end: CameraItem
@export var is_start: bool
@export var is_history: bool
@export var travel_callable: Callable

func _init(_start: CameraItem = null, _end: CameraItem = null, _travel_callable := Callable(), _is_start: bool = true) -> void:
	start = _start
	end = _end
	travel_callable = _travel_callable
	is_start = _is_start
