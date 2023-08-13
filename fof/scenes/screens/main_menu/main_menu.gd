extends Control
signal play_pressed
signal editor_menu_pressed
var screen_change_signals: Array = [\
[editor_menu_pressed, "res://scenes/screens/editor_menu/editor_menu.tscn"],\
]

func _on_play_pressed(): play_pressed.emit()
func _on_editor_menu_pressed(): editor_menu_pressed.emit()
func _on_quit_pressed(): get_tree().quit()
func _on_simulation_pressed(): get_parent().get_parent().sim_pressed()
