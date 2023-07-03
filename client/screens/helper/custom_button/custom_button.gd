@tool
extends Control

var texture_state: int = 0
var on_mouse_entered: bool = false

@export var default: CompressedTexture2D: 
	set(val): $Sprite2D.set_texture(val)
@export var hover: CompressedTexture2D
@export var disabled: CompressedTexture2D

func _ready():
	var def: CompressedTexture2D = $Sprite2D.get_texture()
	pass
func _process(_delta):
	if texture_state == 1:
		$Sprite2D.set_texture(hover)
		texture_state = 0
	
	elif texture_state == 2:
		$Sprite2D.set_texture(default)
		texture_state = 0

	elif texture_state == 3:
		$Sprite2D.set_texture(disabled)
		$MouseCollision.visible = false
		texture_state = 0
func _on_mouse_entered(): on_mouse_entered = true; texture_state = 1
func _on_mouse_exited(): on_mouse_entered = false; texture_state = 2
