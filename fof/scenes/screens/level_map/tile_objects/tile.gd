extends Node3D

var type: String = "tile"
func on_load_info(info: Dictionary, area: int) -> void:
	for child in get_children(): child.queue_free()
	var tile_object_name: String = Helper.tid_to(info.id, area, info.type)
	rotation_degrees.y = info.rotation * 60
	
	if tile_object_name != "null":
		add_child(load("res://assets/models/tiles/" + tile_object_name + ".glb").instantiate())

func set_material(mat: Material) -> void:
	if get_child_count() > 0:
		get_child(0).set_surface_material_override(0, mat)
