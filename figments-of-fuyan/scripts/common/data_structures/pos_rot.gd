class_name PosRot extends Resource

@export var pos: Vector3
@export var rot: Vector3

func _init(_pos := Vector3.ZERO, _rot := Vector3.ZERO) -> void:
	pos = _pos
	rot = _rot
