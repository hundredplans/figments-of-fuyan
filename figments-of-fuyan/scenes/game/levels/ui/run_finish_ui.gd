extends Control

func setInfo() -> void:
	pass

func _on_loss_ui_exit() -> void:
	queue_free()
