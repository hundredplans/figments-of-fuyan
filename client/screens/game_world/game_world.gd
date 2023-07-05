extends Node3D
signal add_to_back_history
signal change_animation_status
signal lobby_camera_travel_main_menu_finished
signal lobby_camera_travel_item_finished
signal lobby_camera_travel_item_started

func load_map(map_name: String) -> Node3D:
	for child in $MainMap.get_children():
		child.queue_free()
	var map: Node3D = load("res://screens/%s/%s.tscn" % [map_name, map_name]).instantiate()
	map.set_name(map_name)
	$MainMap.add_child(map)
	return map
	
func load_lobby_map(map_name: String) -> void:
	var map: Node3D = load_map(map_name)
	map.lobby_camera_travel_item_finished.connect(on_lobby_camera_travel_item_finished)
	map.change_animation_status.connect(func(status: int): change_animation_status.emit(status))
	map.lobby_camera_travel_main_menu_finished.connect(func(): lobby_camera_travel_main_menu_finished.emit())
	map.lobby_camera_travel_item_started.connect(func(x, y): lobby_camera_travel_item_started.emit(x, y))
	
func on_lobby_item_selected(item_id: int) -> void:
	
	if $MainMap.get_child(0).name == "lobby_map":
		$MainMap.get_child(0).on_lobby_item_selected(item_id)

func on_exit_door_exit_game(path: String):
	if $MainMap.get_child(0).name == "lobby_map":
		$MainMap.get_child(0).on_exit_door_exit_game(path)

func on_lobby_camera_travel_item_finished(item: Array) -> void: # [0] func to call when back arrow called
	add_to_back_history.emit([item[0], item[1]])                # [1] lobby item id to go back to (0), maybe unnecessary
	lobby_camera_travel_item_finished.emit(item[2])             # [2] lobby item scene to instance
