@tool
extends UnitVFXBase

@export var ROTATION_SPEED: int = 300
func _process(delta: float) -> void:
	rotation_degrees.y += delta * (ROTATION_SPEED)
