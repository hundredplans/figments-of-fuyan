extends Control

@export var label_name: String
func _ready() -> void:
	$PanelContainer/HBoxContainer/Label.text = label_name
