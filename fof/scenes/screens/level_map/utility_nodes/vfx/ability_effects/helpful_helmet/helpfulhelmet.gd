extends Node3D
const ROTATION_SPEED: int = 20
var type: String

func _process(delta):
	rotation_degrees.y += ROTATION_SPEED * delta

const SCALE_MAX := Vector3(1.1, 1.1, 1.1)
const SCALE_MIN := Vector3(0.9, 0.9, 0.9)
const SCALE_DURATION: float = 2.6

func _ready() -> void:
	onCreateScaleTween(SCALE_MAX)
	$AnimationPlayer.play("TiltHelmet")
	
func onCreateScaleTween(new_scale: Vector3) -> void:
	var ScaleTween := create_tween()
	ScaleTween.tween_property(self, "scale", new_scale, SCALE_DURATION)
	ScaleTween.finished.connect(onCreateScaleTween.bind(SCALE_MAX if new_scale == SCALE_MIN else SCALE_MIN))
