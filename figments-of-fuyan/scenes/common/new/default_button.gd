class_name DefaultButton extends Control

signal pressed
signal mouse_in_ui

@export var BASE_COLOR := Color("ffffff")
@export var HOVER_COLOR := Color("aaaaaa")
@export var DISABLED_COLOR := Color("#888888")
@export var CLICK_NOISE: AudioStreamMP3
@export var HOVER_NOISE: AudioStreamMP3

func _ready() -> void:
	setModulate()

var is_mouse_in_ui: bool
func onMouseInUI(state: bool) -> void:
	mouse_in_ui.emit(state)
	is_mouse_in_ui = state
	
	if is_mouse_in_ui and !disabled and pressable:
		Audio.onSoundEffect(HOVER_NOISE)
		
	setModulate()
	
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
