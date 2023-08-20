extends Control
@onready var screen_change_signals: Array = [
[$Buttons/LeftButtons/EditorMenu/EditorMenu.pressed, "res://scenes/screens/editor_menu/editor_menu.tscn"],
[$Buttons/LeftButtons/Settings/Settings.pressed, "res://scenes/screens/settings_menu/settings_menu.tscn"],
]
func _on_quit_pressed(): get_tree().quit()
func _on_simulation_pressed(): get_parent().get_parent().sim_pressed()
