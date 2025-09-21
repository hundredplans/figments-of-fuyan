extends Control

@onready var TxRect: TextureRect = %TxRect

const USED_COLOR := Color(0.5, 0.5, 0.5)
const MODULATE_TIME: float = 0.2

const SIDE_TILT: float = PI / 8.0
const TILT_TIME: float = 0.1

var is_used: bool
var ModulateTween: Tween
var ScaleTween: Tween

const MAX_SCALE: float = 1.2

func setInfo(is_used: bool) -> void:
	if is_used: onUsed(true)

func onRefreshed() -> void:
	is_used = false
	var tween := create_tween()
	tween.tween_property(TxRect, "rotation", SIDE_TILT, TILT_TIME)
	tween.tween_property(TxRect, "rotation", -SIDE_TILT * 2, TILT_TIME * 2)
	tween.tween_property(TxRect, "rotation", SIDE_TILT, TILT_TIME)
	
	if ScaleTween: ScaleTween.kill()
	ScaleTween = create_tween()
	var new_scale: float = MAX_SCALE - TxRect.scale.x
	ScaleTween.tween_property(TxRect, "scale", Vector2(new_scale, new_scale), TILT_TIME * 2)\
		.as_relative().set_trans(Tween.TRANS_SINE)
	ScaleTween.tween_property(TxRect, "scale", Vector2(-0.1, -0.1), TILT_TIME * 2)\
		.as_relative().set_trans(Tween.TRANS_SINE)
	
	if ModulateTween: ModulateTween.kill()
	ModulateTween = create_tween()
	ModulateTween.tween_property(self, "modulate", Color.WHITE, MODULATE_TIME)
	
func onUsed(instant: bool = false) -> void:
	is_used = true
	if !instant:
		if ModulateTween: ModulateTween.kill()
		ModulateTween = create_tween()
		ModulateTween.tween_property(self, "modulate", USED_COLOR, MODULATE_TIME)
	else: modulate = USED_COLOR
	
func isUsed() -> bool:
	return is_used
