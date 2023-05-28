extends Control

func load_gui(path: String) -> void:
	add_child(load(path).instantiate())
