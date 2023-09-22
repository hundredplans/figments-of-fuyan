extends Control
signal load_info
var base_path: String
var current_path: String

func _ready() -> void:
	$LoadInOut.play_backwards("load_in_out")
	$ExitButton.pressed.connect(func(): Helper.play_method_on_animation_end("load_in_out", $LoadInOut, queue_free, [], false, self))

func on_ready(file_loader_name: String) -> void:
	var path: String = file_loader_name.to_lower() + "s/"
	base_path = path
	current_path = path

