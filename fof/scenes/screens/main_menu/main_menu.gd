extends Control
signal user_quit
@onready var screen_change_signals: Array = [
[$Buttons/LeftButtons/EditorMenu.pressed, "res://scenes/screens/editor_menu/editor_menu.tscn"],
[$Buttons/LeftButtons/Settings.pressed, "res://scenes/screens/settings_menu/settings_menu.tscn"],
[$Buttons/LeftButtons/Fuyanopedia.pressed, "res://scenes/screens/fuyanopedia/fuyanopedia.tscn"],
[$Buttons/LevelEditor.pressed, "res://scenes/screens/level_editor/level_editor.tscn"]
]

func _on_quit_pressed(): get_parent().get_parent().on_user_quit(); get_tree().quit()
func _on_simulation_pressed(): get_parent().get_parent().sim_pressed()
