extends Node3D
var type: String = "tdeco"
func on_load_info(info: Dictionary, btab: int) -> void:
	for child in get_children(): child.queue_free()
	
	var tile_decoration_name: String = Helper.editor_id_to(btab, info.id, info.type)
	rotation_degrees.y = info.rotation * 60
	
	if tile_decoration_name != "null":
		add_child(load("res://assets/models/decorations/tiles/" + tile_decoration_name + ".glb").instantiate())
