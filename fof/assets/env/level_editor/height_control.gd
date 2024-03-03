extends Control

@onready var HeightLabel: Label = $PanelContainer/HBoxContainer/HeightLabel
@onready var GrabButton: Button = %GrabButton
@export var label_name: String
func _ready() -> void:
	$PanelContainer/HBoxContainer/Label.text = label_name

