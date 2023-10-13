extends Control
signal pressed
func _on_button_pressed():
	pressed.emit()
	AudioMaster.play_sfx(preload("res://scenes/screens/main_menu/equipped_theme/0/click.wav"))
