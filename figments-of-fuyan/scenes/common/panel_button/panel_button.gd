extends PanelContainer

signal pressed
signal mouse_in_ui

@export var text: String
@export var label_settings: LabelSettings
@onready var label: Label = %Label

func _ready() -> void:
	label.label_settings = label_settings
	label.text = text
	
func setText(_text: String) -> void:
	label.text = _text

var is_mouse_in_ui: bool
func onMouseInUI(state: bool) -> void:
	mouse_in_ui.emit(state)
	is_mouse_in_ui = state
	if state: modulate = Color(0.6, 0.6, 0.6)
	else: modulate = Color(1, 1, 1)

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("MainInput") and is_mouse_in_ui:
		pressed.emit()
