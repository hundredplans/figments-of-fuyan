extends Control

@export var id: int
signal pressed
var can_press: bool = false

func _process(_delta: float) -> void:
	if can_press and Input.is_action_just_pressed("LeftClick"): pressed.emit(id)

func _on_mouse_entered(): can_press = true
func _on_mouse_exited(): can_press = false
