extends Label

signal pressed
signal mouse_in_ui

@export var BASE_COLOR := Color("ffbd26")
@export var HOVER_COLOR := Color("ffd77a")
@export var DISABLED_COLOR := Color("#856314")

func _ready() -> void:
	setModulate()

var is_mouse_in_ui: bool
func onMouseInUI(state: bool) -> void:
	mouse_in_ui.emit(state)
	is_mouse_in_ui = state
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
		pressed.emit()
