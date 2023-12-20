extends Control

const PRESS_HOLD: float = 0.15
var node_texture: int = 0
var minside: bool = false
var is_pressed: bool = false

signal held
signal pressed
signal remove_node_texture

func _process(_delta: float) -> void:
	if minside and Input.is_action_just_pressed("RightClick"): remove_node_texture.emit(self, 0)
	elif minside and !is_pressed and Input.is_action_just_pressed("LeftClick"):
		get_tree().create_timer(PRESS_HOLD).timeout.connect(on_pressed)
		is_pressed = true

func _on_node_texture_mouse_entered(): minside = true
func _on_node_texture_mouse_exited(): minside = false

func on_pressed() -> void:
	is_pressed = false
	
	if !Input.is_action_pressed("LeftClick"): pressed.emit(self)
	else: held.emit(self)
