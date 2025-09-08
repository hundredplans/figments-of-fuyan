extends Control

signal pressed

@onready var ExitLabel: Label = %ExitLabel
@export var exit_screen: Control
@export var label_settings: LabelSettings
var disabled: bool

func _on_pressed() -> void:
	if disabled: return
	if exit_screen != null: exit_screen.queue_free()
	pressed.emit()

func setDisabled(_disabled: bool) -> void:
	disabled = _disabled
	ExitLabel.setDisabled(disabled)

func _ready() -> void:
	if label_settings != null:
		ExitLabel.label_settings = label_settings
