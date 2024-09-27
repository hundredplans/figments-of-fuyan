extends Camera3D

signal camera_panning
var ANTI_INTERACT_BUTTON: int = MOUSE_BUTTON_RIGHT
@export var disable_freelook: bool
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		# Receives mouse button input
		match event.button_index:
			ANTI_INTERACT_BUTTON: # Only allows rotation if right click down
				if !disable_freelook:
					camera_panning.emit(event.is_pressed())
					Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED if event.pressed else Input.MOUSE_MODE_VISIBLE)
