extends Node3D
@export var texture: Texture2D

func _ready() -> void:
	$Sprite3D.texture = texture

func setInfo(i: int) -> void:
	$Label3D.text = str(i)
