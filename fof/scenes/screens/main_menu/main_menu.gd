extends Control
signal user_quit
@onready var screen_change_signals: Array = [
[$Buttons/LeftButtons/EditorMenu/EditorMenu.pressed, "res://scenes/screens/editor_menu/editor_menu.tscn"],
[$Buttons/LeftButtons/Settings/Settings.pressed, "res://scenes/screens/settings_menu/settings_menu.tscn"],
]
func _on_quit_pressed(): get_parent().get_parent().on_user_quit(); get_tree().quit()
func _on_simulation_pressed(): get_parent().get_parent().sim_pressed()

@onready var click_sfx: AudioStreamWAV = preload("res://assets/sounds/UI/menu_buttons/click.wav")
func on_menu_button_pressed(): AudioMaster.play_sfx(click_sfx)
