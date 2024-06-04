extends Control
@export var icon: Texture2D

func _ready():
	$Sprite2D.texture = icon

func setAIStat(i: int) -> void:
	$Label.text = str(i)
