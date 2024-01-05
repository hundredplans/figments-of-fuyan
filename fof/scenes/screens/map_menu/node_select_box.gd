extends Control

@export var id: int
signal pressed
signal node_hovered
var can_press: bool = false

func _process(_delta: float) -> void:
	if can_press and Input.is_action_just_pressed("LeftClick"): pressed.emit(id, get_index())

func _on_mouse_entered(): can_press = true; node_hovered.emit(can_press, get_index())
func _on_mouse_exited(): can_press = false; node_hovered.emit(can_press, get_index())
