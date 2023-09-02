extends Control
signal load_info
var base_path: String
var current_path: String

func on_ready(file_loader_name: String) -> void:
	var path: String = file_loader_name.to_lower() + "s/"
	base_path = path
	current_path = path

