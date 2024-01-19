class_name TileGD
extends Node3D

var area: int = 0
@export var info: Dictionary
func on_load_info(type: String) -> void:
	type = type.to_lower()
	match type:
		"tile", "wall", "obj": on_get_node_by_type(type).on_load_info(info[type], area)
		"tdeco", "wdeco": on_get_node_by_type(type).on_load_info(info[type], Helper.TYPE_TO_BTAB[type])

func on_get_node_by_type(type: String) -> Node3D:
	for child in get_children():
		if child.type == type:
			return child
	return null
