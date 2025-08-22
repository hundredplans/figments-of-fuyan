extends Control

const UP_MAX: float = -100.0
const FADE_EFFECT_START: float = 0.5
const EFFECT_DURATION: float = 1.5
const ADD_SCALE: float = 1.0

@onready var PriceDisplay: Label = %PriceDisplay
func setShillings(shillings: int) -> void:
	PriceDisplay.text = ("+" if shillings > 0 else "") + str(shillings)
	PriceDisplay.modulate = Color.WHITE if shillings >= 0 else Color.RED

func setInfo(shillings: int, start_position: Vector2) -> void:
	position = start_position - pivot_offset
	setShillings(shillings)
	var tween := create_tween()
	tween.tween_property(self, "scale", Vector2(ADD_SCALE, ADD_SCALE), EFFECT_DURATION).as_relative().set_trans(Tween.TRANS_SINE)
	
	var mtween := create_tween()
	mtween.tween_property(self, "position:y", UP_MAX, EFFECT_DURATION).as_relative().set_trans(Tween.TRANS_SINE)
	
	await get_tree().create_timer(FADE_EFFECT_START).timeout
	var ntween := create_tween()
	ntween.tween_property(self, "modulate:a", 0.0, EFFECT_DURATION - FADE_EFFECT_START)
	
	await ntween.finished
	queue_free()
