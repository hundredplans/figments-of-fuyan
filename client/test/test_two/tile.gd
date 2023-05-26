extends Node3D
var listen: bool = false
signal tile_inputA
signal tile_inputB

func _on_hover_collision_mouse_entered() -> void:
	listen = true

func _on_hover_collision_mouse_exited() -> void:
	listen = false
	
func _process(_delta: float) -> void:
	if listen:
		var signal_to_input: Dictionary = {
		"InputA": tile_inputA,
		"InputB": tile_inputB
		}
		
		for input_str in signal_to_input:
			if Input.is_action_just_pressed(input_str):
				signal_to_input[input_str].emit(self)
		
