extends Node3D

var _normalized_travelled_distance: float = 0
var fade_in: int = 0
func ready_with_direction(direction: bool) -> void:
	if !direction: fade_in = 1
	$Sprite3D.modulate = Color(1, 1, 1, int(!direction))

func on_camera_distance_travelled(normalized_travelled_distance: float):
	_normalized_travelled_distance = normalized_travelled_distance
	
func _process(_delta: float):
	_normalized_travelled_distance = clamp(abs(_normalized_travelled_distance - fade_in), 0, 1)
	$Sprite3D.modulate = Color(1, 1, 1, _normalized_travelled_distance)
