class_name HighlightTxButton extends TextureButton

var mouse_in_ui: bool
func _on_mouse_entered() -> void:
	mouse_in_ui = true
	if !disabled: modulate = Color(0.8, 0.8, 0.8)

func _on_mouse_exited() -> void:
	mouse_in_ui = false
	if !disabled: modulate = Color(1, 1, 1)

func setDisabled(state: bool) -> void:
	disabled = state
	
	if disabled: modulate = Color(0.3, 0.3, 0.3)
	elif mouse_in_ui: _on_mouse_entered()
	else: _on_mouse_exited()
