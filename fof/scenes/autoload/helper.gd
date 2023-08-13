extends Node
signal add_screen_history
signal screen_change_animation_state

func call_method(node: Node, method: String, args: Array) -> bool:
	if node.has_method(method):
		node.call(method, args)
		return true
	return false

func on_exit_screen(screen: Control, old_screen: Control):
	play_method_on_animation_end("move_screen", old_screen.get_node("MoveScreen"), on_exit_screen_animation_finished, [screen, old_screen], false)
	screen_change_animation_state.emit(true)

func on_exit_screen_animation_finished(screen: Control, old_screen: Control) -> void:
	on_enter_screen(screen)
	old_screen.queue_free()

func on_enter_screen(screen: Control) -> void:
	get_parent().get_node("Main/Screens").add_child(screen)
	play_method_on_animation_end("move_screen", screen.get_node("MoveScreen"), on_enter_screen_animation_finished, [], true)
	add_screen_history.emit(screen.scene_file_path)
	screen_change_animation_state.emit(true)

func on_enter_screen_animation_finished() -> void:
	screen_change_animation_state.emit(false)

func play_method_on_animation_end(animation_name: String, animation_player: AnimationPlayer, method: Callable, args: Array, backwards: bool) -> void:
	var animation: Animation = animation_player.get_animation(animation_name)
	var track_index: int = animation.add_track(Animation.TYPE_METHOD)
	animation.track_set_path(track_index, get_path())
	var length: float = animation.length
	if backwards: length = 0
	animation.track_insert_key(track_index, length, {"method": method.get_method(), "args": args})
	
	match backwards:
		false: animation_player.play(animation_name)
		true: animation_player.play_backwards(animation_name)

var pure_characters: Array = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z",\
"A", "B", "C", "D", "E", "F", 'G', "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z",\
"0", "1", "2", "3", "4", "5", "6", "7", "8", "9",\
"_", "'"]
var reserved_file_names: Array = ["CON", "PRN", "AUX", "NUL"]
var reserved_file_names_loop: Array = ["COM", "LPT"]

func purify_file_name(file_name: String) -> String:
	if file_name not in reserved_file_names:
		for reserved_file_name in reserved_file_names_loop:
			for i in range(0, 10):
				if file_name == reserved_file_name + str(i): return ""
		
		for character in file_name: if character not in pure_characters: return ""
		return file_name
	return ""
