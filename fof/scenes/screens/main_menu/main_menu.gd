extends Control
signal play_pressed
signal editor_menu_pressed

@onready var exit_screen: AnimationPlayer = $ExitScreen

func _on_play_pressed(): play_pressed.emit()
func _on_editor_menu_pressed(): editor_menu_pressed.emit()
func _on_quit_pressed(): get_tree().quit()

func _on_simulation_pressed(): get_parent().get_parent().sim_pressed()

func on_exit_screen(args: Array) -> void:
	var screen: Control = args[0]
	Helper.play_method_on_animation_end("exit_screen_animation", exit_screen, on_exit_screen_animation_finished, [screen])
	
func on_exit_screen_animation_finished(screen: Control) -> void:
	Helper.on_enter_screen(screen)
	queue_free()
