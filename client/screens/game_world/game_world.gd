extends Node3D
@export var lobby_camera_position := Vector3(-1.692, 2.498, 7.86)
@export var lobby_camera_rotation := Vector3(-12.2, 24.3, 0)

func load_map(map_name: String) -> void:
	
	for child in $MainMap.get_children():
		child.queue_free()
		
	var map: Node3D = load("res://screens/%s/%s.tscn" % [map_name, map_name]).instantiate()
	map.set_name(map_name)
	$MainMap.add_child(map)
func load_lobby_map(map_name: String) -> void:
	load_map(map_name)
	$CameraBody.on_teleport_camera(lobby_camera_position, lobby_camera_rotation)
