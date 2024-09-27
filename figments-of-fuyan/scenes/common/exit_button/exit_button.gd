extends Button

@export var exit_screen: Control


func _on_pressed() -> void:
	if exit_screen != null: exit_screen.queue_free()
