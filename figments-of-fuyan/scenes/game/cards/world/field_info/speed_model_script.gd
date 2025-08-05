extends Node3D

const ANGLE_DEGREES: float = 10.0
const ROT_TIME: float = 1.0

var direction: int = 1

func _ready():
	onLoop()
	
func onLoop() -> void:
	var tween := create_tween()
	tween.tween_property(self, "rotation_degrees:z", ANGLE_DEGREES * direction, ROT_TIME).as_relative().set_trans(Tween.TRANS_SINE)
	direction *= -1
	await tween.finished
	onLoop()
