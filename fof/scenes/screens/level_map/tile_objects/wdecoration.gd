extends Node3D
var type: String = "wdeco"
var btab: int = 4

func on_load_info(info: Dictionary) -> void:
	for child in get_children(): child.queue_free()
	
	var wall_decoration_name: String = Helper.editor_id_to(btab, info.id, info.type)
	rotation_degrees.y = info.rotation * 60
	
	if wall_decoration_name != "null":
		add_child(load("res://assets/models/decorations/walls/" + wall_decoration_name + ".glb").instantiate())

func set_material(mat: Material) -> void:
	if get_child_count() > 0:
		get_child(0).set_surface_material_override(0, mat)
