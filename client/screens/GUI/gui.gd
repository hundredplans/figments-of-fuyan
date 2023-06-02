extends Control

func load_gui(path: String) -> void:
	
	for child in $MainScreen.get_children():
		child.queue_free()
		
	$MainScreen.add_child(load(path).instantiate())
