extends Control

signal pressed

@onready var ExitLabel: Label = %ExitLabel
@export var exit_screen: Control
@export var label_settings: LabelSettings

func _on_pressed() -> void:
	if exit_screen != null: exit_screen.queue_free()
	pressed.emit()

func _ready() -> void:
	if label_settings != null:
		ExitLabel.label_settings = label_settings
