extends Node3D

var flip: int = -1
const ROTATE_SPEED: int = 2
@onready var camera: Camera3D = $Camera3D

func _ready(): camera.rotation_degrees.y = 270

func _process(delta: float) -> void:
	camera.rotation_degrees.y += (delta * ROTATE_SPEED) * flip
	if camera.rotation_degrees.y >= 300: flip = -1
	elif camera.rotation_degrees.y <= 240: flip = 1
