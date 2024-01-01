extends Node3D

var map_id: int = 0
var area_id: int = 0

func _ready():
	var area_map: Node3D = load("res://assets/base_game/areas/" + Helper.id_to_dict(area_id, "Area").bgfn + "/area_map.tscn").instantiate()
	add_child(area_map)
	
	var Markers: Node3D = area_map.get_node("Markers")
	var map_info: Dictionary = Helper.id_to_dict(map_id, "Map")
	for node_info in map_info.nodes:
		if node_info[0] != 0:
			Markers.get_child(node_info[2]).get_child(node_info[1]).add_child(\
			load("res://assets/env/area_map/map_nodes/" + str(node_info[0]) +".glb").instantiate())
