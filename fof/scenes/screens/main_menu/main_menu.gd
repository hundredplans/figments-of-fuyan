extends Control
signal play_pressed

func _on_play_pressed(): play_pressed.emit()
func _on_quit_pressed(): get_tree().quit()
func _on_simulation_pressed(): get_parent().get_parent().sim_pressed()
