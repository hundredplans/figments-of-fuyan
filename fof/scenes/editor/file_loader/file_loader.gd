extends Control

@export var SearchEdit: LineEdit
@export var Items: Control
const static_path: String = "res://static/base_game/"
const ITEM_COUNT_ON_ONE_PAGE: int = 10

signal item_selected
var search_item_selected: int = 0
var current_page: int = 1
var button_size: Vector2i

var all_item_buttons: Array
var item_buttons: Array

var item_name: String
var base_path: String
var current_path: String

func _ready() -> void:
	on_change_fileloader_state(1)
	Helper.play_method_on_animation_end("load_in_out", $LoadInOut, on_change_fileloader_state,  [2], true, self)
	$ExitButton.pressed.connect(on_exit_button_pressed)
	$Background.modulate = Color(1, 1, 1, Settings.fileloader_opacity * 0.01)

func on_change_fileloader_state(i: int) -> void:
	get_parent().change_fileloader_state.emit(i)

func on_exit_button_pressed() -> void:
	if !$LoadInOut.is_playing():
		on_change_fileloader_state(1)
		Helper.play_method_on_animation_end("load_in_out", $LoadInOut, _queue_free, [], false, self)

func _queue_free() -> void:
	on_change_fileloader_state(0)
	queue_free()

func on_ready(_item_name: String) -> void:
	item_name = _item_name.to_lower()
	var path: String = item_name + "s/"
	base_path = static_path + path
	current_path = static_path + path
	
	on_item_ready()
	
	var item_button_path: PackedScene = load("res://scenes/editor/file_loader/" + item_name + "/" + item_name + "_button.tscn")
	var set_button_size: bool = false
	for item_dict in Helper.return_file_names_recursive(base_path.left(-1)).map(func(x: String): return Helper.return_item_dict(item_name, Helper.return_file_contents(x))):
		var item_button: Control = item_button_path.instantiate()
		item_button.get_node("PressedButton").pressed.connect(on_item_selected.bind(item_button, item_dict))
		item_button.get_node("ID").text = str(item_dict.id)
		item_button.info = item_dict
		item_button.apply_info()
		all_item_buttons.append(item_button)
		
		if !set_button_size:
			button_size = item_button.size
			set_button_size = true
	
	item_buttons = all_item_buttons
	item_buttons.sort_custom(func(a: Control, b: Control): return int(a.get_node("ID").text) < int(b.get_node("ID").text))
	position_item_buttons()

func on_item_ready() -> void:
	
	var search_options: PackedStringArray = []
	match item_name:
		"area": search_options = ["World"]
		"card": search_options = ["Rarity", "Attack", "Health", "Speed", "Energy", "Confidence", "Intelligence", "Awareness", "Teamwork", "Adventurousness", "Ability"]

	$Search/SearchOptions.options += search_options
		
	
func on_item_selected(_item: Control, item_info: Dictionary) -> void:
	item_selected.emit(item_info)
	if Helper.return_bitwise(item_info.tid, int(Settings.close_fileloader.x), int(Settings.close_fileloader.y)):
		on_exit_button_pressed()
	
func position_item_buttons() -> void:
	for button in Items.get_children(): Items.remove_child(button)
	var xy := Vector2.ZERO
	var xdelta: int = int(Items.size.x * 0.2)
	var ydelta: int = int(Items.size.y) - button_size.y
	
	var j: int = 0
	for i in range(max(0, (current_page * ITEM_COUNT_ON_ONE_PAGE) - ITEM_COUNT_ON_ONE_PAGE), min(current_page * ITEM_COUNT_ON_ONE_PAGE, item_buttons.size())):
		Items.add_child(item_buttons[i])
		item_buttons[i].position = xy
		xy.x += xdelta
		if j == 4:
			xy.x = 0
			xy.y += ydelta
		j += 1
	
func change_page(i: int) -> void:
	current_page = clamp(current_page + i, 1, ceil((item_buttons.size() + 1) * 0.1))
	position_item_buttons()

func _on_search_item_selected(i: int):
	search_item_selected = i
	refresh_search()

func refresh_search() -> void:
	item_buttons = []
	for btn in all_item_buttons:
		if SearchEdit.text.length() > 2 or SearchEdit.text.is_valid_int():
			if match_search_item_selected(btn):
				item_buttons.append(btn)
		else: item_buttons.append(btn)
	current_page = 1
	position_item_buttons()

func match_search_item_selected(btn: Control) -> bool:
	match search_item_selected:
		0: if (btn.info.sname.to_lower()).begins_with(SearchEdit.text.to_lower()):
			return true
		1: if str(btn.info.id).begins_with(SearchEdit.text):
			return true
			
		2: if (btn.info.iname.to_lower()).begins_with(SearchEdit.text.to_lower()):
			return true
		3:
			match item_name:
				"area": if str(btn.info.world).begins_with(SearchEdit.text): return true
				"card": if str(btn.info.r).begins_with(SearchEdit.text): return true
		4: if str(btn.info.a).begins_with(SearchEdit.text): return true
		5: if str(btn.info.h).begins_with(SearchEdit.text): return true
		6: if str(btn.info.s).begins_with(SearchEdit.text): return true
		7: if str(btn.info.e).begins_with(SearchEdit.text): return true
		8: if str(btn.info.aic).begins_with(SearchEdit.text): return true
		9: if str(btn.info.aii).begins_with(SearchEdit.text): return true
		10: if str(btn.info.aiw).begins_with(SearchEdit.text): return true
		11: if str(btn.info.ait).begins_with(SearchEdit.text): return true
		12: if str(btn.info.aia).begins_with(SearchEdit.text): return true
		13: return true
	return false

func _on_search_edit_text_changed(__: String):
	refresh_search()
