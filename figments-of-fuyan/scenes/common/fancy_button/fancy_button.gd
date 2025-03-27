extends Control

signal mouse_in_ui
signal pressed

const DISABLED_COLOR := Color(0.2, 0.2, 0.2)

@onready var FancyLabel: FancyTextLabel = %FancyLabel

@export var text: String
@export var settings: FancyTextLabelSettings
func _ready() -> void:
	setSettings(settings)
	setText(text)
	
func setText(_text: String) -> void:
	FancyLabel.setText(_text)

func setSettings(_settings: FancyTextLabelSettings) -> void:
	FancyLabel.settings = _settings

var is_mouse_in_ui: bool
func onMouseInUI(_is_mouse_in_ui: bool) -> void:
	is_mouse_in_ui = _is_mouse_in_ui
	mouse_in_ui.emit(is_mouse_in_ui)
	onUpdateModulate()

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("MainInput") and is_mouse_in_ui and !disabled:
		pressed.emit()
		
var disabled: bool
func setDisabled(state: bool) -> void:
	disabled = state
	onUpdateModulate()
	
func onUpdateModulate() -> void:
	if !disabled:
		if is_mouse_in_ui: modulate = Color(0.6, 0.6, 0.6)
		else: modulate = Color(1, 1, 1)
	else: modulate = DISABLED_COLOR
