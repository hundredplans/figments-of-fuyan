extends Control

@export var Items: Control
const static_path: String = "res://static/base_game/"
const ITEM_COUNT_ON_ONE_PAGE: int = 10

signal item_selected
var current_page: int = 1
var button_size: Vector2i
var item_buttons: Array
var item_name: String
var base_path: String
var current_path: String

func _ready() -> void:
	$LoadInOut.play_backwards("load_in_out")
	$ExitButton.pressed.connect(on_exit_button_pressed)
	$Background.modulate = Color(1, 1, 1, Settings.fileloader_opacity * 0.01)

func on_exit_button_pressed() -> void:
	Helper.play_method_on_animation_end("load_in_out", $LoadInOut, queue_free, [], false, self)

func on_ready(_item_name: String) -> void:
	item_name = _item_name.to_lower()
	var path: String = item_name + "s/"
	base_path = static_path + path
	current_path = static_path + path
	
	var item_button_path: PackedScene = load("res://scenes/editor/file_loader/" + item_name + "/" + item_name + "_button.tscn")
	var set_button_size: bool = false
	for item_dict in Helper.return_file_names_recursive(base_path.left(-1)).map(func(x: String): return Helper.return_item_dict(item_name, Helper.return_file_contents(x))):
		var item_button: Control = item_button_path.instantiate() 
		item_button.pressed.connect(on_item_selected)
		item_button.set_info(item_dict)
		item_buttons.append(item_button)
		
		if !set_button_size:
			button_size = item_button.size
			set_button_size = true
	
	item_buttons.sort_custom(func(a: Control, b: Control): return int(a.get_node("ID").text) < int(b.get_node("ID").text))
	position_item_buttons()
	
func on_item_selected(_item: Control, item_info: Dictionary) -> void:
	item_selected.emit(item_info)
	if Helper.return_bitwise(item_info.tid, Settings.close_fileloader.x, Settings.close_fileloader.y):
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
