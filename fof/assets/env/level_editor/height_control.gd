extends Control

@export var color: Color
@onready var HeightLabel: Label = $PanelContainer/HBoxContainer/HeightLabel
@onready var GrabButton: Button = %GrabButton
@export var label_name: String
@onready var GrabberBackground: ColorRect = %GrabberBackground

func _ready() -> void:
	$PanelContainer/HBoxContainer/Label.text = label_name
	GrabberBackground.color = color
