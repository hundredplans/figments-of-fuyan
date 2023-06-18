extends Node3D
signal add_to_back_history
signal change_animation_status

func load_map(map_name: String) -> Node3D:
	for child in $MainMap.get_children():
		child.queue_free()
	var map: Node3D = load("res://screens/%s/%s.tscn" % [map_name, map_name]).instantiate()
	map.set_name(map_name)
	$MainMap.add_child(map)
	return map
	
func load_lobby_map(map_name: String) -> void:
	var map: Node3D = load_map(map_name)
	map.add_to_back_history.connect(func(item: Array): add_to_back_history.emit(item))
	map.change_animation_status.connect(func(status: int): change_animation_status.emit(status))
