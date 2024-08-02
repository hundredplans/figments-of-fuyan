extends Node3D

signal fell
@export var spin_speed: float = 50
@export var falling_speed: float = 2

var callable: Callable
var stop_falling: float
func setInfo(_callable: Callable, _stop_falling: float) -> void:
	callable = _callable
	stop_falling = _stop_falling

func _process(delta: float) -> void:
	position.y -= falling_speed * delta
	rotation_degrees.y += spin_speed * delta
	rotation_degrees.x += spin_speed * delta
	
	if position.y < stop_falling:
		queue_free()
		callable.call()
		fell.emit()
