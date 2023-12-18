extends Control

@export var SearchEdit: LineEdit
@export var Items: Control
const static_path: String = "res://static/base_game/"

signal queued
signal item_selected
var search_item_selected: int = 0
var item_name: String

func _ready() -> void:
	on_change_fileloader_state(1)
	Helper.play_method_on_animation_end("load_in_out", $LoadInOut, on_change_fileloader_state, [2], true, self)
	$ExitButton.pressed.connect(on_exit_button_pressed)
	$Background.modulate = Color(1, 1, 1, Settings.fileloader_opacity * 0.01)
func on_change_fileloader_state(i: int) -> void:
	get_tree().get_root().get_node("Main").fileloader_state = i
func on_exit_button_pressed() -> void:
	if !$LoadInOut.is_playing():
		on_change_fileloader_state(1)
		Helper.play_method_on_animation_end("load_in_out", $LoadInOut, _queue_free, [], false, self)
		for button in Items.get_children().map(func(x: Control): return x.get_node("PressedButton")):
			button.disabled = true
func _queue_free() -> void:
	on_change_fileloader_state(0)
	queued.emit()
	queue_free()

func on_ready(_item_name: String) -> void:
	item_name = _item_name.to_lower()
	var path: String = item_name + "s/"
	on_item_ready()
	
	all_item_buttons = Helper.return_file_names_recursive((static_path + path).left(-1)).map(func(x: String): return Helper.return_item_dict(item_name, Helper.return_file_contents(x)))
	all_item_buttons.sort_custom(func(a: Dictionary, b: Dictionary): return a.id < b.id)
	item_buttons = all_item_buttons.duplicate()
	on_reload_page(0)

func on_ready_preselected(_item_name: String, items: Array) -> void:
	item_name = _item_name.to_lower()
	on_item_ready()
	
	all_item_buttons = items
	all_item_buttons.sort_custom(func(a: Dictionary, b: Dictionary): return a.id < b.id)
	item_buttons = all_item_buttons.duplicate()
	
	on_reload_page(0)

func on_item_ready() -> void:
	var search_options: PackedStringArray = []
	match item_name:
		"area": search_options = ["World"]
		"card": search_options = ["Rarity", "Attack", "Health", "Speed", "Energy", "Confidence", "Intelligence", "Awareness", "Teamwork", "Adventurousness", "Ability"]
		"level": search_options = ["Area"]
		"tool": search_options = ["Rarity"]
		"boon": search_options = ["Rarity"]
	$Search/SearchOptions.options += search_options
	_item_button = load("res://scenes/editor/file_loader/" + item_name + "/" + item_name + "_button.tscn")
	
func on_item_selected(_item: Control, item_info: Dictionary) -> void:
	item_selected.emit(item_info)
	if Helper.return_bitwise(item_info.tid, Settings.close_fileloader):
		on_exit_button_pressed()

func _on_search_item_selected(i: int):
	search_item_selected = i
	refresh_search()

func refresh_search() -> void:
	if SearchEdit.text.length() > 0:
		item_buttons = []
		for item_dict in all_item_buttons:
			if match_search_item_selected(item_dict):
				item_buttons.append(item_dict)
	else:
		item_buttons = all_item_buttons.duplicate()
	page = 0
	on_reload_page(0)

func match_search_item_selected(item_dict: Dictionary) -> bool:
	match search_item_selected:
		0: return item_dict.sname.to_lower().begins_with(SearchEdit.text.to_lower())
		1: return str(item_dict.id) == SearchEdit.text
		2: return item_dict.iname.to_lower().begins_with(SearchEdit.text.to_lower())
		3: 
			match item_name:
				"area": return item_dict.world.begins_with(SearchEdit.text)
				"card", "tool", "boon": return str(item_dict.r) == SearchEdit.text
				"level":
					if str(item_dict.area).begins_with(SearchEdit.text): return true
					var area_info: Dictionary = Helper.id_to_dict(item_dict.area, "Area")
					return area_info and area_info.sname.to_lower().begins_with(SearchEdit.text.to_lower())
		4:  return str(item_dict.a) == SearchEdit.text
		5: return str(item_dict.h) == SearchEdit.text
		6: return str(item_dict.s) == SearchEdit.text
		7: return str(item_dict.e) == SearchEdit.text
		8: return str(item_dict.aic) == SearchEdit.text
		9: return str(item_dict.aii) == SearchEdit.text
		10: return str(item_dict.aiw) == SearchEdit.text
		11: return str(item_dict.ait) == SearchEdit.text
		12: return str(item_dict.aia) == SearchEdit.text
		13: 
			var contents: String = Helper.return_file_contents("res://scenes/editor/file_loader/card/abilities.txt")
			var ltext: String = item_dict.text.to_lower()
			for i in contents.split("\n", false):
				if i.begins_with(SearchEdit.text) and ltext.contains(i):
					return true
	return false

func _on_search_edit_text_changed(__: String):
	refresh_search()

func set_search(text: String, i: int) -> void:
	SearchEdit.text = text
	$Search/SearchOptions.select_item(i)
	_on_search_item_selected(i) 
	
var MAX_PAGE_COUNT: int = 12
var page: int = 0
var all_item_buttons: Array = []
var item_buttons: Array = []
var _item_button: PackedScene

func on_reload_page(i: int) -> void:
	var max_page: int = floor(max(item_buttons.size() - 1, 1) / MAX_PAGE_COUNT)
	if page + i == -1: page = max_page
	elif page + i > max_page: page = 0
	else: page = clamp(page + i, 0, max_page)
	$PageArrows/Page.text = str(page)
	
	for child in Items.get_children(): child.queue_free()
	
	var xy := Vector2(50, 50)
	for j in range(page * MAX_PAGE_COUNT, min((page + 1) * MAX_PAGE_COUNT, item_buttons.size())):
		var item_button: Control = _item_button.instantiate()
		Items.add_child(item_button)
		item_button.position = xy
		item_button.get_node("PressedButton").pressed.connect(on_item_selected.bind(item_button, item_buttons[j]))
		item_button.get_node("ID").text = str(item_buttons[j].id)
		item_button.info = item_buttons[j]
		item_button.apply_info()
		
		xy.x += 300
		if xy.x == 1850:
			xy.x = 50
			xy.y += 400
