extends Control
var can_drag: bool = false
var drag_mode: bool = false
var eye_mode: bool = false
func _on_destroy_pressed():
	queue_free()

func _on_drag_zone_mouse_entered():
	can_drag = true

func _on_drag_zone_mouse_exited():
	can_drag = false
	
func _process(_delta: float) -> void:
	if can_drag and drag_mode:
		if Input.is_action_pressed("LeftClick"):
			position.x = (get_viewport().get_mouse_position().x) - ($Out.size.x / 2) 
			position.y = (get_viewport().get_mouse_position().y) - ($Out.size.y / 2) 

func _on_drag_pressed():
	drag_mode = !drag_mode
	match drag_mode:
		false: $Drag.modulate = Color(1,1,1,1)
		true: $Drag.modulate = Color(1,0,0,1)

func _on_eye_button_pressed():
	eye_mode = !eye_mode
	match eye_mode:
		false: $EyeButton.modulate = Color(1,1,1,1)
		true: $EyeButton.modulate = Color(1,0,0,1)
