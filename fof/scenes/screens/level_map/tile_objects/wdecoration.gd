extends Node3D
var type: String = "wdeco"
func on_load_info(info: Dictionary, btab: int) -> void:
	for child in get_children(): child.queue_free()
	
	var wall_decoration_name: String = Helper.editor_id_to(btab, info.id, info.type)
	rotation_degrees.y = info.rotation * 60
	
	if wall_decoration_name != "null":
		add_child(load("res://assets/models/decorations/walls/" + wall_decoration_name + ".glb").instantiate())
