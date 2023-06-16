extends Node3D
 
func load_map(map_name: String) -> void:
	for child in $MainMap.get_children():
		child.queue_free()
	var map: Node3D = load("res://screens/%s/%s.tscn" % [map_name, map_name]).instantiate()
	map.set_name(map_name)
	$MainMap.add_child(map)
func load_lobby_map(map_name: String) -> void:
	load_map(map_name)
