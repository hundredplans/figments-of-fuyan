extends Control

func _on_loss_button_pressed() -> void:
	Game.save_file.onGameLost()
