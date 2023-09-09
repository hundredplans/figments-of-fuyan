extends Control

var can_drag: bool = false
var held: bool = true

func _process(_delta: float) -> void:
	if can_drag or held:
		if Input.is_action_just_pressed("LeftClick"):
			held = true
		elif Input.is_action_pressed("LeftClick") and held:
			position.x = (get_viewport().get_mouse_position().x) - 500
			position.y = (get_viewport().get_mouse_position().y) - 100
		else:
			held = false
func _on_grab_zone_mouse_entered():
	can_drag = true
func _on_grab_zone_mouse_exited():
	can_drag = false
func _on_remove_button_pressed():
	queue_free()
