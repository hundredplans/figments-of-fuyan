extends Node

var main: Node

const YELLOW := Color(1, 0.965, 0, 1)
const BLACK := Color(1, 1, 1, 1)
const RED := Color(1,0,0,1)
const BASE := Color(1,1,1,1)
const LIGHT_BROWN := Color(0.635, 0.447, 0.31,1)
const DARK_BROWN := Color(0.165, 0.075, 0.008,1)
const LIGHT_GREY := Color("828282")
const DARK_GREY := Color("3d3d3d")

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

const rarity_boon_tool_colors: Dictionary = {
	0: "606060", # Mini
	1: "606060", # Scrap
	2: "ce9f80", # Common
	3: "00946d", # Rare
	4: "f7ce00", # Exalt
	5: "ad0000", # Boss
}

const rarity_colors: Dictionary = {
	0: "5b3a24", # Neutral
	1: "606060", # Scrap
	2: "ce9f80", # Common
	3: "00946d", # Rare
	4: "f7ce00", # Exalt
	5: "7300a8", # Mini-boss
	6: "ad0000", # Boss
	7: "5f91e1", # Champion
}
	
const rarity_accent_colors: Dictionary = {
	0: "6d6e67",
	1: "6d6e67",
	2: "97846b",
	3: "476900",
	4: "bfb32f",
	5: "8001ca",
	6: "a81a00",
	7: "467ace",
}

const rarity_secondary_colors: Dictionary = {
	0: "808080",
	1: "ce9f80",
	2: "00c48f",
	3: "ffdd47",
	4: "ad0000",
	5: "c27fb7",
	6: "00bf18",
}

const rarity_secondary_accent_colors: Dictionary = {
	0: "606060",
	1: "825841",
	2: "00946d",
	3: "f7ce00",
	4: "540000",
	5: "62335b",
	6: "004c04",
}

const task_primary_colors: Dictionary = {
	0: "8fdb6d",
	1: "f1f829",
	2: "fb3415",
}

const task_accent_colors: Dictionary = {
	0: "70c44a",
	1: "d6da51",
	2: "ad3e21",
}

const area_to_default_ground: Dictionary = {
	1: "SandWalk"
}

const node_type_to_light: Dictionary = {
	1: "727272",
	2: "ff4239",
	3: "b409b7",
	4: "93001d",
	5: "ffcc09",
	6: "1af90d",
}

func call_method(node: Node, method: String, args: Array) -> bool:
	if node.has_method(method):
		node.call(method, args)
		return true
	return false
	
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

func return_new_highest_id(dir_path: String, file_name: String, ITEM_NAME: String, set_id_text: String) -> String:
	var total: int = 0
	var item_array: Array = Array(DirAccess.get_files_at(dir_path))\
	.map(func(x: String): return id_to_dict(int(x.get_slice("-", 0)), ITEM_NAME))
	
	item_array.sort_custom(func(a: Dictionary, b: Dictionary): return a.id < b.id)
	for item in item_array:
		if item.iname == file_name or set_id_text == str(item.id): return str(item.id)
		elif total == item.id - 1: total = item.id
	return set_id_text if set_id_text else is_level_id(ITEM_NAME, total + 1)

func is_level_id(item: String, id: int) -> String:
	if item == "level" and Settings.level_id > 0:
		if (Settings.level_id == 2 and id % 2 == 1) or (Settings.level_id == 1 and id % 2 == 0): id += 1
		while(id_to_dict(id, "Level")): id += 2
	return str(id)

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
		var id: String = return_new_highest_id(dir, file_name, item, "" if !(edit_file_name.get_node("SetID").has_checked) else edit_file_name.get_node("SetID").text)
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
			"oldcard": keys += ["a", "h", "s", "e", "r", "text", "flavor", "aic", "aii", "aiw", "ait", "aia", "height"]
			"level": keys += ["area", "difficulty", "trinkets", "tiles", "level_size"]
			"tool": keys += ["r", "text", "utext"]
			"boon": keys += ["r", "text", "utext"]
			"map": keys += ["world", "map_size", "nodes", "arrows"]
			"trinket", "challenge": keys += ["text"]
			"task": keys += ["text", "difficulty"]
			"encounter": keys += ["text", "options"]
			
		item_dict = on_convert_type(keys, contents)
		item_dict.merge({"bgfn": str(item_dict.id) + " - " + item_dict.iname})
	return item_dict

func on_convert_type(keys: Array, contents: Array) -> Dictionary:
	var item_dict: Dictionary = {}
	var i: int = 0
	for key in keys:
		if contents[i].is_valid_int() and key not in ["pcolor", "acolor"]:
			contents[i] = int(contents[i])
		
		elif contents[i].begins_with("(") and contents[i].ends_with(")"):
			contents[i] = str_to_var("Color" + contents[i])
			
		elif contents[i].begins_with("[") and contents[i].ends_with("]"):
			contents[i] = str_to_var(contents[i])
			
		elif contents[i].begins_with("{"):
			contents[i] = str_to_var(contents[i])
			
		item_dict.merge({key: contents[i]})
		i += 1
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

func getTileFromCollision(collision: Node) -> TileGD:
	collision = collision.get_node("../../..")
	if collision is TileGD: return collision
	
	var parent: Variant = collision.get_parent()
	if parent is TileGD: return parent
	return parent.get_parent().Tile

func create_button_clickmask(button: TextureButton) -> void:
	var img: Image = load(button.texture_normal.resource_path.left(-4) + "_image.png")
	button.texture_click_mask = onCreateClickmask(img)

func onCreateClickmask(image: Image) -> BitMap:
	var bitmap := BitMap.new()
	bitmap.create_from_image_alpha(image)
	return bitmap

func on_delete_item(item: String, ID: String, Internal: LineEdit, node: Control, can_del_dir: int) -> void:
	item = item.to_lower() + "s/"
	var file_valid: bool = Internal.text.length() > 0 and FileAccess.file_exists("res://static/base_game/"  + item + ID + " - " + Internal.text + ".fof")
	if file_valid:
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
		if Settings.clear_backup_files_array[Settings.clear_backup_files] != 0:
			write_to_file("user://save/temp/" + item, Internal.text, ".fof", contents, false)
		if can_del_dir == 1:
			DirAccess.remove_absolute("res://assets/base_game/" + item + base_game_file_name)

func id_to_dict(i: int, item: String) -> Dictionary:
	item = item.to_lower() + "s/"
	var dir_path: String = "res://static/base_game/" + item
	for file_path in DirAccess.get_files_at(dir_path):
		if int(file_path.split(" ")[0]) == i:
			return return_item_dict(item.left(-2), return_file_contents(dir_path + file_path))
	return {}
	
func on_item_dicts(item: String) -> Array:
	item = item.to_lower() + "s/"
	var dir_path: String = "res://static/base_game/" + item
	return Array(DirAccess.get_files_at(dir_path)).map(func(x: String): return return_item_dict(item.left(-2), return_file_contents(dir_path + x)))
	
func id_to_bgfn(i: int, item: String) -> String: return id_to_dict(i, item).bgfn
	
func load_area_colors(node: Node, primary_color: Color, accent_color: Color) -> void:
	for child in get_children_recursive(node):
		if child.name.begins_with("PR"):
			if child is ColorRect: child.color = primary_color
			else: child.modulate = primary_color
		elif child.name.begins_with("AC"):
			if child is ColorRect: child.color = accent_color
			else: child.modulate = accent_color

var exclude_fill: Array = []

var _id_to: Array = [
	["null", "ground", "_hover", "water/shallow_water", "water/deep_water", "_default_tile", "palms/sand_tile", "palms/beach_tile", "palms/sand_road_tile",
	"palms/sand_tile_trapped", "palms/sand_tile_reward"],
	
	["null", "spawns/spawn_enemy", "spawns/spawn_ally", "spawns/spawn_neutral", 
	"spawns/spawn_trinket", "palms/ziplines/palm_zipline_equal_long", "palms/ziplines/palm_zipline_equal_short",
	"palms/ziplines/palm_zipline_high_long", "palms/ziplines/palm_zipline_high_short", "palms/palm_fireplace", 
	"palms/doors/palm_door", "palms/doors/palm_door_short", "palms/heal_coconut", "palms/coconut_tree",
	"palms/coconut_effigy_bad", "palms/coconut_effigy_good", "palms/stick", "palms/halfeaten_coconut", "palms/palmleaf",
	"palms/sand_larva", "palms/bag_of_sand"],
	
	["null", "wall", "wooden_wall"],
	
	["null", "general/shrub", "general/rock", "palms/palm_tree", "palms/palmrock", "palms/coconut_pile", "palms/coconut_pile_big", "palms/coconut_floor"],
	
	["null"]]
	
func wid_to(id: int, area: int = 0, type: int = 0) -> String:
	var contents: Array = _id_to[2][id].split("/")
	var middle: String = (str(area) + "wall" if id == 1 else contents.pop_back())
	if type > 0:
		if type > 2:
			middle = middle.insert(0, "_")
			type -= 3
		if type > 0: middle += str(type)
	
	if id != 1:
		for n in contents: middle = middle.insert(0, n + "/")
	return middle
	
func tid_to(id: int, area: int = 0, type: int = 0) -> String:
	var contents: Array = _id_to[0][id].split("/")
	var middle: String = str(area) + "tile" if id == 1 else contents.pop_back()
	if type > 0: middle += str(type)
	if id != 1:
		for n in contents: middle = middle.insert(0, n + "/")
	return middle
	
func editor_id_to(btab: int, id: int, type: int = 0) -> String:
	return _id_to[btab][id] + ("" if type == 0 else str(type))
	
func id_to_editor(btab: int, item: String) -> int:
	item = item.left(-4)
	var j: int = 0
	var sp: Array = item.split("/")
	var _adjusted: String = sp.pop_back().substr(1, item.length())
	var fu: String = ""
	for n in sp: fu += n + "/"
	fu += _adjusted
	for i in _id_to[btab]:
		if item.begins_with(i) or fu.begins_with(i):
			return j
		j += 1

	return 1 if btab in [0, 2] else 0
	
func flip(x: bool): return !x
	
func interact_button(_flip: bool = false) -> String:
	return ["RightClick", "MouseMiddle"][abs(Settings.interact_button - int(_flip))]

func on_timer_end(function: Callable, args: Array, delay: float):
	var tween: Tween = get_tree().create_tween()
	tween.tween_callback(function.bindv(args)).set_delay(delay)

func create_base_game_id_dir(item_dict: Dictionary, file_loader_name: String) -> void:
	if item_dict and Settings.auto_create_dir == 1:
		var dir_path: String = "res://assets/base_game/" + file_loader_name.to_lower() + "s/"
		if !Array(DirAccess.get_directories_at(dir_path)).any(func(x: String): return x.begins_with(str(item_dict.id))):
			DirAccess.make_dir_absolute(dir_path + item_dict.bgfn)

func compare_by_value(a: Array, b: Array) -> bool:
	for n in range(a.size()):
		if a[n] != b[n]: return false
	return true

var cube_directions: Array[Vector3] = [Vector3(1, 0, -1), Vector3(1, -1, 0), Vector3(0, -1, 1), Vector3(-1, 0, 1), Vector3(-1, 1, 0), Vector3(0, 1, -1)]
func position_to_vec(pos: Array) -> Vector4:
	return Vector4(pos[0], pos[1], pos[2], pos[3])

func vec_to_position(pos: Vector4) -> Array:
	return [pos.x, pos.y, pos.z, pos.w]

func hex_neighbours(tile: Node3D, tiles: Array, distance: int = 1, search_elevation: bool = false) -> Array:
	return _hex_neighbours(tile.info.position, tiles.map(func(x: Node3D): return x.info.position), distance, search_elevation)\
	.map(func(x: Vector4): return tiles.filter(func(y: Node3D): return y.info.position == x)[0])
	
func _hex_neighbours(tile: Vector4, tiles: Array, distance: int = 1, search_elevation: bool = false) -> Array:
	return tiles.filter(_is_hex_neighbour.bind(tile, distance, search_elevation))
	
func is_hex_neighbour(tile: Node3D, otile: Node3D, distance: int = 1, search_elevation: bool = false) -> void:
	return _is_hex_neighbour(tile.info.position, otile.info.position, distance, search_elevation)
	
func _is_hex_neighbour(tile: Vector4, otile: Vector4, distance: int = 1, search_elevation: bool = false) -> bool:
	if search_elevation: if tile.z != otile.z: return false
	if Vector3(tile.x, tile.y, tile.z) - Vector3(otile.x, otile.y, otile.z) in cube_directions.map(func(x: Vector3): return x * distance): return true
	return false

func return_multi_tile(id: Array) -> Array:
	var datas: Array = Helper.return_file_contents("res://static/game_info/item_properties.txt").split("\n", false)
	for _data in datas:
		var data: Dictionary = str_to_var(_data)
		if compare_by_value(data.id, id):
			var arr: Array = [[0, 0, 0, 0]]
			for key in data:
				if key.contains("|") and key != "0|0|0":
					var k: Array = Array(key.split("|", false)).map(func(x: String): return int(x))
					arr.append([k[0], k[1], -k[0] - k[1], k[2]])
			return arr
	return []

func flatten(arr: Array, remove_duplicates: bool) -> Array:
	var narr: Array = []
	for a in arr: 
		if remove_duplicates and a in narr: continue
		narr += a
	return narr

var _GameState: PackedScene = preload("res://scenes/autoload/game_state/game_state.tscn")
var GameState: GameStateGD

func onStartNewGame(hid: int, gseed: int) -> void:
	Helper.on_load_game_state(0)
	GameState.onCreateSaveInfo(hid, gseed)
	
func on_load_game_state(save_file: int) -> void:
	GameState = _GameState.instantiate()
	if save_file != 0: GameState.save_info = load("user://save/save_files/" + str(save_file) + ".tres")
	add_child(GameState)
	main.GameState = GameState

var settings_loaded: bool = false
const TYPE_TO_BTAB: Dictionary = {
	"tile": 0,
	"obj": 1,
	"wall": 2,
	"tdeco": 3,
	"wdeco": 4,
}

const BTAB_TO_TYPE: Dictionary = {
	-1: ["tile", "obj", "wall", "tdeco", "wdeco"],
	0: "tile",
	1: "obj",
	2: "wall",
	3: "tdeco",
	4: "wdeco",
}

const NUM_TO_STRING_NUM: Dictionary = {
	0: "zero",
	1: "one",
	2: "two",
	3: "three",
	4: "four",
	5: "five",
	6: "six",
	7: "seven",
	8: "eight",
	9: "nine",
	"+": "plus",
	"-": "minus"
}

func onStatParticleStrNum(x: Variant) -> String:
	match x:
		0: return "zero"
		1: return "one"
		2: return "two"
		3: return "three"
		4: return "four"
		5: return "five"
		6: return "six"
		7: return "seven"
		8: return "eight"
		9: return "nine"
		"+": return "plus"
		"-": return "minus"
		_: return "exclamation_mark"
	
func getHeroCardInfo(hid: int) -> HeroCardGD:
	var DIR_PATH: String = "res://assets/base_game/cards/cards/"
	for dir in DirAccess.get_directories_at(DIR_PATH):
		for file in DirAccess.get_files_at(DIR_PATH + dir):
			if file.begins_with("base_card"):
				var hero_card: FofInfoGD = load(DIR_PATH + dir + "/" + file)
				if hero_card is HeroCardGD and hero_card.hero_id == hid: return hero_card
	return null

var cards: Array = []
func _ready() -> void:
	var DIR_PATH: String = "res://assets/base_game/cards/cards/"
	
	var base_cards: Array = []
	for dir in DirAccess.get_directories_at(DIR_PATH):
		for file in DirAccess.get_files_at(DIR_PATH + dir):
			if file.begins_with("base_card"):
				base_cards.append(load(DIR_PATH + dir + "/" + file))
				
	base_cards.sort_custom(func(x: Variant, y: Variant): return x.id < y.id)
	
	var i: int = 0
	for base_card in base_cards:
		while (base_card.id != i):
			cards.append(null)
			i += 1
		i += 1
		cards.append(base_card)
	
	
func getCard(id: int) -> BaseCardGD:
	if GameState == null: return cards[id]
	else:
		if cards[id] is HeroCardGD:
			return cards[id].base_cards[GameState.save_info.hero_level]
		return cards[id]
	

func getAllLevelInfo() -> Array:
	var levels: Array = []
	var DIR_PATH: String = "res://assets/base_game/levels/levels/"
	for dir in DirAccess.get_directories_at(DIR_PATH):
		for file in DirAccess.get_files_at(DIR_PATH + dir):
			if file.begins_with("level_info"):
				levels.append(load(DIR_PATH + dir + "/" + file))
	return levels
	
const FOF_INFO_DIR_PATHS: Dictionary = {
	"level": "res://assets/base_game/levels/levels/",
	"card": "res://assets/base_game/cards/cards/",
	"area": "res://assets/base_game/areas/"
}

const FOF_INFO_BEGIN_BY: Dictionary = {
	"level": "level_info",
	"card": "base_card",
	"area": "area_info",
}

func getFofInfo(condition: Variant, info_type: String = "card", match_by: String = "id") -> Variant:
	var DIR_PATH: String = FOF_INFO_DIR_PATHS[info_type]
	for dir in DirAccess.get_directories_at(DIR_PATH):
		for file in DirAccess.get_files_at(DIR_PATH + dir):
			if file.begins_with(FOF_INFO_BEGIN_BY[info_type]):
				var info: Variant = load(DIR_PATH + dir + "/" + file)
				if condition == info[match_by]:
					return info
	return null

var references: Array = []
func setUtilityNodesPaths(_references: Array) -> void:
	references = _references
	for child in references: onCreateChildReferences(child)
	
func onCreateChildReferences(obj: Object) -> void:
	for child in references.filter(func(x: Node): return x.name in obj):
		if child != obj: obj[child.name] = child
