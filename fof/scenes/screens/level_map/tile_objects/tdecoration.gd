extends Node3D
var type: String = "tdeco"
var btab: int = 3
func on_load_info(info: Dictionary) -> void:
	for child in get_children(): child.queue_free()
	
	var tile_decoration_name: String = Helper.editor_id_to(btab, info.id, info.type)
	rotation_degrees.y = info.rotation * 60
	
	if tile_decoration_name != "null":
		add_child(load("res://assets/models/decorations/tiles/" + tile_decoration_name + ".tscn").instantiate())

func set_material(mat: Material) -> void:
	if get_child_count() > 0:
		for child in get_child(0).get_children():
			child.set_surface_override_material(0, mat)
