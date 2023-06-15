extends Node3D
const lobby_camera_posrot_path := "res://static_data/lobby_camera_posrot.json"
@onready var lcps = Helper.load_json(lobby_camera_posrot_path)

func load_map(map_name: String) -> void:
	for child in $MainMap.get_children():
		child.queue_free()
		
	var map: Node3D = load("res://screens/%s/%s.tscn" % [map_name, map_name]).instantiate()
	map.set_name(map_name)
	$MainMap.add_child(map)
func load_lobby_map(map_name: String) -> void:
	load_map(map_name)
	$CameraBody.on_teleport_camera(lcps.position, lcps.rotation_degrees)
