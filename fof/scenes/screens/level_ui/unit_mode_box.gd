extends Control
@onready var label: Label = %Label
@onready var description: RichTextLabel = %Description
@onready var ChargesLabel: Label = %ChargesLabel
@onready var button: TextureButton = %Button
var trigger: Object
signal pressed
signal mouse_in_ui

func _ready() -> void:
	button.pressed.connect(func(): pressed.emit())
	button.mouse_in_ui.connect(func(x: bool): mouse_in_ui.emit(x))

func setDisabled(x: bool) -> void:
	button.setDisabled(x)

func setInfo(_trigger: Object) -> void:
	trigger = _trigger
	if trigger is ToolGD or IObjectGD:
		description.script = preload("res://assets/base_game/oldcards/card_ui/text_processing.gd")
		description.text = description.on_apply_text_processing(description.text)
