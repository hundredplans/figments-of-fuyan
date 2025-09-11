class_name DefaultButton extends Control

signal pressed
signal mouse_in_ui

@export var SCALE_SPEED: float = 0.25
@export var SCALE_MAX: float = 1.1

@export var autoscale: bool
@export var BASE_COLOR := Color("ffffff")
@export var HOVER_COLOR := Color("aaaaaa")
@export var DISABLED_COLOR := Color("#888888")
@export var CLICK_NOISE: AudioStreamMP3 = load("res://assets/sounds/ui/default_press.mp3")
@export var HOVER_NOISE: AudioStreamMP3 = load("res://assets/sounds/ui/default_hover.mp3")

func _ready() -> void:
	setModulate()

var is_mouse_in_ui: bool
func onMouseInUI(state: bool) -> void:
	mouse_in_ui.emit(state)
	is_mouse_in_ui = state
	
	if is_mouse_in_ui and !disabled and pressable:
		Audio.onSoundEffect(HOVER_NOISE)
		
	setModulate()
	if !autoscale or disabled: return
	onScaleSize(is_mouse_in_ui)
	
func setModulate() -> void:
	modulate = (BASE_COLOR if !is_mouse_in_ui else HOVER_COLOR) if !disabled else DISABLED_COLOR
	
var disabled: bool
func setDisabled(state: bool) -> void:
	disabled = state
	
	if is_mouse_in_ui:
		onMouseInUI(false)
		
	setModulate()
	
var pressable: bool = true
func setPressable(state: bool) -> void:
	pressable = state
	
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("MainInput") and is_mouse_in_ui and !disabled and pressable:
		onPressed()
		
func onPressed() -> void:
	pressed.emit()
	Audio.onSoundEffect(CLICK_NOISE)
	
func onChangeHoverColor(color: Color) -> void:
	HOVER_COLOR = color
	setModulate()

var ScaleTween: Tween
func onScaleSize(state: bool, instant: bool = false) -> void:
	var target_value: float = (SCALE_MAX if state else 1.0) - scale.x
	if !instant:
		if ScaleTween: ScaleTween.kill()
		ScaleTween = create_tween()
		ScaleTween.tween_property(self, "scale", Vector2(target_value, target_value), SCALE_SPEED)\
				.as_relative().set_trans(Tween.TRANS_SINE)
	else: scale += Vector2(target_value, target_value)
