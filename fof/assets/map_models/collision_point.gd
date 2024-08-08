extends Node3D

signal remove_collision_point
var point: Vector3
var mouse_state: bool
var enabled: bool = true

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("LeftClick") and mouse_state and enabled:
		queue_free()
		remove_collision_point.emit(point)

func onChangeMouseState(x: bool) -> void: mouse_state = x
