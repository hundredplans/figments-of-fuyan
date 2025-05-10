extends ColorRect

signal mouse_in_ui
@export var FADE_TIME: float = 0.25
@export var DEFAULT_ALPHA: int = 192

@export var FADE_COLOR: Color = Color("ffbe26")

func _ready() -> void:
	pass

func onMouseInUI(state: bool) -> void:
	mouse_in_ui.emit(state)

func onFade(fade_in: bool) -> void:
	var fade_value: float = float(DEFAULT_ALPHA) / 255.0 if fade_in else 0.0
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", fade_value, FADE_TIME)
	
	if FADE_COLOR == color: return
	var color_tween := get_tree().create_tween()
	color_tween.tween_property(self, "color", FADE_COLOR, FADE_TIME)
