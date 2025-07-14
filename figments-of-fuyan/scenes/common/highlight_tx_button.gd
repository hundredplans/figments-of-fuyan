class_name HighlightTxButton extends TextureButton

signal mouse_in_ui
var is_mouse_in_ui: bool
func _on_mouse_entered() -> void:
	onMouseInUI(true)
	setModulate()

func _on_mouse_exited() -> void:
	onMouseInUI(false)
	setModulate()
	
func onMouseInUI(state: bool) -> void:
	is_mouse_in_ui = state
	mouse_in_ui.emit(state)
	
func setModulate() -> void:
	modulate = Color(0.5, 0.5, 0.5) if disabled else\
		(Color(0.8, 0.8, 0.8) if is_mouse_in_ui else Color.WHITE)

func setDisabled(state: bool) -> void:
	disabled = state
	setModulate()
	get_viewport().update_mouse_cursor_state()
