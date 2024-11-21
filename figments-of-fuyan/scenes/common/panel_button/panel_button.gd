extends PanelContainer

signal pressed
signal mouse_in_ui

const DISABLED_COLOR := Color(0.2, 0.2, 0.2)

@export var autowrap: bool
@export var text: String
@export var label_settings: LabelSettings
@onready var label: Label = %Label

func _ready() -> void:
	label.label_settings = label_settings
	label.text = text
	
func setText(_text: String) -> void:
	label.text = _text
	label.autowrap_mode = TextServer.AUTOWRAP_WORD if autowrap else TextServer.AutowrapMode.AUTOWRAP_OFF

var disabled: bool
var is_mouse_in_ui: bool
func onMouseInUI(state: bool) -> void:
	mouse_in_ui.emit(state)
	is_mouse_in_ui = state
	
	if !disabled:
		if state: modulate = Color(0.6, 0.6, 0.6)
		else: modulate = Color(1, 1, 1)
	else: modulate = DISABLED_COLOR
	
func setDisabled(state: bool) -> void:
	disabled = state
	if disabled:
		modulate = DISABLED_COLOR

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("MainInput") and is_mouse_in_ui and !disabled:
		pressed.emit()
