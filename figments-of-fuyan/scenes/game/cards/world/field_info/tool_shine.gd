extends Sprite3D

@export var ROTATION_SPEED: float = 100
func _process(delta: float) -> void:
	rotation_degrees.y += (ROTATION_SPEED * delta)
