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
	
const stat_ai_dict: Dictionary = {
	"aii": "Intelligence",
	"ait": "Teamwork",
	"aiw": "Awareness", 
	"aia": "Adventurousness",
	"aic": "Confidence",
	"a": "Attack",
	"h": "Health",
	"s": "Speed",
	"e": "Energy",
	"r": "Rarity",
}

var _id_to_tile: Array = ["null_tile", "hover_tile"]

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
	if old_screen.has_method("_queue_free"):
		old_screen._queue_free()
	old_screen.queue_free()

func on_enter_screen(screen: Control) -> void:
	get_parent().get_node("Main/Screens").add_child(screen)
	get_parent().get_node("Main").on_connect_screen_signals(screen)
	play_method_on_animation_end("move_screen", screen.get_node("MoveScreen"), on_enter_screen_animation_finished, [], true)
	add_screen_history.emit(screen.scene_file_path)
	screen_change_animation_state.emit(true)

func on_enter_screen_animation_finished() -> void:
	screen_change_animation_state.emit(false)
	
func play_method_on_animation_end(animation_name: String, animation_player: AnimationPlayer, method: Callable, args: Array, backwards: bool, call_on=self) -> void:
	var animation: Animation = animation_player.get_animation(animation_name)
	var track_index: int = animation.add_track(Animation.TYPE_METHOD)
	animation.track_set_path(track_index, call_on.get_path())
	var length: float = animation.length
	if backwards: length = 0
	animation.track_insert_key(track_index, length, {"method": method.get_method(), "args": args})
	animation_player.animation_finished.connect(on_animation_finished_remove_track.bind(animation_player, track_index))
	match backwards:
		false: animation_player.play(animation_name)
		true: animation_player.play_backwards(animation_name)

func on_animation_finished_remove_track(animation_name: String, animation_player: AnimationPlayer, i: int) -> void:
	animation_player.get_animation(animation_name).remove_track(i)
	animation_player.animation_finished.disconnect(on_animation_finished_remove_track)

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
		var arr: Array = Array(dir.get_files())
		arr.sort_custom(func(a: String, b: String): return int(a.get_slice(" ", 0)) < int(b.get_slice(" ", 0)))
		for file in arr:
			var file_name_info: Array = file.split("-", false)
			var file_id: int = int(file_name_info[0])
			if file_name_info[1].right(-1).left(-4) == file_name: return file_id
			id += 1
			if file_id != id: return id
			
	id += 1
	return id

func return_file_contents(file_path: String) -> String:
	if FileAccess.file_exists(file_path):
		return FileAccess.open(file_path, FileAccess.READ).get_as_text()
	return ""

func write_to_base_game_file(item: String, edit_file_name: Control, contents: String, TID: int) -> Dictionary:
	item = item.to_lower()
	var file_name: String = edit_file_name.get_node("Internal").text
	var showcase_name: String = edit_file_name.get_node("Showcase").text
	var dir: String = "res://static/base_game/" + item + "s/"
	if is_file_name_pure(file_name):
		var id: String = str(return_new_highest_id(dir, file_name))
		contents = contents.insert(0, "%s\n%s\n%s\n%s\n") % [id, TID, file_name, showcase_name]
		file_name = file_name.insert(0, "%s - " % id)
		write_to_file(dir, file_name, ".fof", contents, false)
		return return_item_dict(item, contents)
	else: print_debug("Your file name is not pure: " + file_name)
	return {}

func create_file(dir: String, file_name: String, extension: String, contents:String="") -> bool:
	var existing_contents: String = return_file_contents(dir + file_name + extension)
	if !existing_contents: existing_contents = contents
	return write_to_file(dir, file_name, extension, existing_contents)

func return_file_names_recursive(path: String, contents := []) -> Array:
	contents += Array(DirAccess.get_files_at(path)).map(func(x: String): return path + "/" + x)
	for dir in DirAccess.get_directories_at(path):
		contents = return_file_names_recursive(path + "/" + dir, contents)
	return contents

func write_to_file(dir: String, file_name: String, extension: String, contents: String, test_purity:bool=true) -> bool:
	if !test_purity or is_file_name_pure(file_name):
		var file := FileAccess.open(dir + file_name + extension, FileAccess.WRITE)
		file.store_string(contents)
		file = null
		return true
	else: print_debug("Your file name is not pure: " + file_name)
	return false

func get_children_recursive(node: Node, children := []):
	children.append(node)
	for child in node.get_children():
		children = get_children_recursive(child, children)
	return children

func start_timer_attach_method(timer: Timer, wait_time: float, method: Callable, args=[], one_shot=true) -> void:
	timer.one_shot = one_shot
	timer.start(wait_time)
	timer.timeout.connect(on_timeout_disconnect.bind(timer, method))
	if args: timer.timeout.connect(method.bind(args))
	else: timer.timeout.connect(method)

func on_timeout_disconnect(timer: Timer, method: Callable) -> void:
	timer.timeout.disconnect(method)
	timer.timeout.disconnect(on_timeout_disconnect)

func delete_file(dir: String, file: String, extension: String) -> void:
	if FileAccess.file_exists(dir + file + extension):
		DirAccess.remove_absolute(dir + file + extension)

func is_upper(i: String) -> bool:
	if i.to_upper() == i and i != " ":
		return true
	return false

func return_item_dict(item: String, _contents: String) -> Dictionary:
	var item_dict: Dictionary = {}
	if _contents:
		var contents: Array = _contents.split("\n")
		var keys: Array[String] = ["id", "tid", "iname", "sname"]
		match item:
			"area": keys += ["pcolor", "acolor", "world", "cards"]
			"card": keys += ["a", "h", "s", "e", "r", "text", "flavor", "aic", "aii", "aiw", "ait", "aia"]
		
		var i: int = 0
		for key in keys:
			if contents[i].is_valid_int():
				contents[i] = int(contents[i])
			
			elif contents[i].begins_with("(") and contents[i].ends_with(")"):
				contents[i] = str_to_var("Color" + contents[i])
				
			elif contents[i].begins_with("[") and contents[i].ends_with("]"):
				contents[i] = str_to_var(contents[i])
				
			item_dict.merge({key: contents[i]})
			i += 1
		item_dict.merge({"bgfn": str(item_dict.id) + " - " + item_dict.iname})
	return item_dict

func return_bitwise(i: int, total: Vector2i) -> bool:
	var k: int = 0
	while total.x > 0:
		if total.x >= total.y:
			total.x -= total.y
			if k == i: return true
		total.y = int(total.y * 0.5)
		k += 1
	return false

func create_button_clickmask(button: TextureButton) -> void:
	var img: Image = load(button.texture_normal.resource_path.left(-4) + "_image.png")
	var bitmap := BitMap.new()
	bitmap.create_from_image_alpha(img)
	button.texture_click_mask = bitmap

func on_delete_item(item: String, ID: String, Internal: LineEdit, node: Control, can_del_dir: int) -> void:
	item = item.to_lower() + "s/"
	var file_valid: bool = Internal.text.length() > 0 and FileAccess.file_exists("res://static/base_game/"  + item + ID + " - " + Internal.text + ".fof")
	var delete_prompt: Control = preload("res://scenes/editor/delete_prompt/delete_prompt.tscn").instantiate()
	node.add_child(delete_prompt)
	delete_prompt.delete_item.connect(on_delete_item_confirmed.bind(item, ID, Internal, can_del_dir))
	delete_prompt.on_ready(Settings.confirm_file_delete, Internal.text, file_valid)
		
func on_delete_item_confirmed(item: String, ID: String, Internal: LineEdit, can_del_dir: int) -> void:
	var base_game_file_name: String = ID + " - " + Internal.text
	var dir: String = "res://static/base_game/" + item
	var contents: String = Helper.return_file_contents(dir + base_game_file_name + ".fof")
	if contents:
		delete_file(dir, base_game_file_name, ".fof")
		write_to_file("user://save/temp/" + item, Internal.text, ".fof", contents, false)
		if can_del_dir == 1:
			DirAccess.remove_absolute("res://assets/base_game/" + item)

func id_to_dict(i: int, item: String) -> Dictionary:
	item = item.to_lower() + "s/"
	var dir_path: String = "res://static/base_game/" + item
	for file_path in DirAccess.get_files_at(dir_path):
		if int(file_path.split(" ")[0]) == i:
			return return_item_dict(item.left(-2), return_file_contents(dir_path + file_path))
	return {}
	
func load_area_colors(node: Node, primary_color: Color, accent_color: Color) -> void:
	for child in get_children_recursive(node):
		if child.name.begins_with("PR"):
			if child is ColorRect: child.color = primary_color
			else: child.modulate = primary_color
		elif child.name.begins_with("AC"):
			if child is ColorRect: child.color = accent_color
			else: child.modulate = accent_color

func id_to_tile(id: int) -> String:
	return _id_to_tile[id]
	
