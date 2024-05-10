extends Node3D

var type: String = "Stagger"
const SCALE_MAX := Vector3(1.2, 1.2, 1.2)
const SCALE_MIN := Vector3(0.8, 0.8, 0.8)
const SCALE_DURATION: float = 2.6
const STAGGER_ROTATION_SPEED: int = 15

func _ready() -> void:
	onCreateScaleTween(SCALE_MAX)
	
func onCreateScaleTween(new_scale: Vector3) -> void:
	var ScaleTween := create_tween()
	ScaleTween.tween_property(self, "scale", new_scale, SCALE_DURATION)
	ScaleTween.finished.connect(onCreateScaleTween.bind(SCALE_MAX if new_scale == SCALE_MIN else SCALE_MIN))

func _process(delta):
	rotation_degrees.y += STAGGER_ROTATION_SPEED * delta
