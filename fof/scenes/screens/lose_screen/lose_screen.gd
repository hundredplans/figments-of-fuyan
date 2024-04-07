extends Control
signal screen_change_sig
signal load_world
var save_file: int = 0

func _ready() -> void:
	save_file = GameState.save_file
	GameState._queue_free()
	load_world.emit(null)
	
var GameState: Node
func _on_continue_button_pressed():
	screen_change_sig.emit("res://scenes/screens/main_menu/main_menu.tscn")
	DirAccess.remove_absolute("user://save/save_files/" + str(save_file) + ".txt")
	
