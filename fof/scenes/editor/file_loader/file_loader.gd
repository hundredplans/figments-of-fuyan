extends Control

const static_path: String = "res://static/base_game/"
var items: Array
var item_name: String
var base_path: String
var current_path: String

func _ready() -> void:
	$LoadInOut.play_backwards("load_in_out")
	$ExitButton.pressed.connect(func(): Helper.play_method_on_animation_end("load_in_out", $LoadInOut, queue_free, [], false, self))

func on_ready(_item_name: String) -> void:
	item_name = _item_name.to_lower()
	var path: String = item_name + "s/"
	base_path = static_path + path
	current_path = static_path + path
	items = Helper.return_file_names_recursive(base_path.left(-1)).map(func(x: String): Helper.return_file_contents(x))
	print(items)
