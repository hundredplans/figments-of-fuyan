extends Node
signal add_screen_history
signal screen_change_animation_state

const RED := Color(1,0,0,1)
const BASE := Color(1,1,1,1)
const LIGHT_BROWN := Color(0.635, 0.447, 0.31,1)
const DARK_BROWN := Color(0.165, 0.075, 0.008,1)

const settings_color_dict: Dictionary = {
	"Graphics": "fcc71d",
	"Audio": "0bc1dd",
	"Video": "4f9c00",
	"Preferences": "4f2a00",
	"Controls": "bc57ef",}

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
	get_parent().get_node("Main").on_connect_screen_signals(screen)
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
"_", "'"," "]
var reserved_file_names: Array = ["CON", "PRN", "AUX", "NUL"]
var reserved_file_names_loop: Array = ["COM", "LPT"]

func is_file_name_pure(file_name: String) -> bool:
	if file_name not in reserved_file_names and file_name.length() >= 2:
		for reserved_file_name in reserved_file_names_loop:
			for i in range(0, 10):
				if file_name == reserved_file_name + str(i): return false
		
		for character in file_name: if character not in pure_characters: return false
		return true
	return false

func return_new_highest_id(dir_path: String, file_name: String) -> int:
	var dir := DirAccess.open(dir_path)
	var id: int = 0
	if dir != null:
		for file in dir.get_files():
			var file_name_info: Array = file.split("-", false)
			var file_id: int = int(file_name_info[0])
			if file_name_info[1].right(-1).left(-4) == file_name: return file_id
			if file_id > id: id = file_id
	id += 1
	return id

func return_file_contents(file_path: String) -> String:
	if FileAccess.file_exists(file_path):
		var file: FileAccess = FileAccess.open(file_path, FileAccess.READ)
		return file.get_as_text()
	return ""

func write_to_base_game_file(dir: String, edit_file_name: Control, contents: String) -> void:
	var file_name: String = edit_file_name.get_node("Internal").text
	var showcase_name: String = edit_file_name.get_node("Showcase").text
	if is_file_name_pure(file_name):
		if dir.begins_with("res://static/base_game/"):
			var id: String = str(return_new_highest_id(dir, file_name))
			contents = contents.insert(0, "%s\n%s\n%s\n") % [id, file_name, showcase_name]
			file_name = file_name.insert(0, "%s - " % id)
			write_to_file(dir, file_name, ".fof", contents)
		else: print_debug("You are not writing to the correct directory")
	else: print_debug("Your name is not pure")

func write_to_file(dir: String, file_name: String, extension: String, contents: String) -> void:
	var file := FileAccess.open(dir + file_name + extension, FileAccess.WRITE)
	file.store_string(contents)
	file = null

func get_children_recursive(node: Node, children := []):
	children.append(node)
	for child in node.get_children():
		children = get_children_recursive(child, children)
	return children
