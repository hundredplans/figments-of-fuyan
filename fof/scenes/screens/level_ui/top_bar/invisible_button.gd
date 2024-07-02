@tool
extends Control
@export var texture: Texture2D
func _ready() -> void:
	$Sprite2D.texture = texture
