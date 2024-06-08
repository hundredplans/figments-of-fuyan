extends Node3D

const SPIN_SPEED: int = 300
var type: String
func _process(delta):
	rotation_degrees.y += SPIN_SPEED * delta
