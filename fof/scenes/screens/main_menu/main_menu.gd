extends Control
signal play_pressed
signal editor_menu_pressed

var exit_screen_new_screen: Control
@onready var exit_screen: AnimationPlayer = $ExitScreen

func _on_play_pressed(): play_pressed.emit()
func _on_editor_menu_pressed(): editor_menu_pressed.emit()
func _on_quit_pressed(): get_tree().quit()

func _on_simulation_pressed(): get_parent().get_parent().sim_pressed()

func on_exit_screen(args: Array) -> void:
	var screen: Control = args[0]
	exit_screen.play("exit_screen_animation")
	exit_screen_new_screen = screen
	
func on_exit_screen_animation_finished() -> void:
	Helper.on_enter_screen(exit_screen_new_screen)
	queue_free()
