extends Node3D

var area: int = 0
var tile_info: Dictionary
func on_load_info(type: String) -> void:
	type = type.to_lower()
	match type:
		"tile", "wall": get_node(type).on_load_info(tile_info[type], area)
		"tdeco", "wdeco": get_node(type).on_load_info(tile_info[type], Helper.TYPE_TO_BTAB[type])
	
	
	
