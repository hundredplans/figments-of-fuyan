extends MapNodeScreen

func onDimBackground() -> bool: return true

func _on_play_button_pressed() -> void:
	pass # Replace with function body.

func _on_leave_button_pressed() -> void:
	finished.emit()
	queue_free()
