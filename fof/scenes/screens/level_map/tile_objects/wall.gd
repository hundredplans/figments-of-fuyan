extends Node3D

var type: String = "wall"
func on_load_info(info: Dictionary, area: int) -> void:
	for child in get_children(): child.queue_free()
	
	var wall_name: String = Helper.wid_to(info.id, area, info.type)
	rotation_degrees.y = info.rotation * 60
	if wall_name != "null":
		for n in range(4 - info.tile_wall):
			var wall: Node3D = load("res://assets/models/walls/" + wall_name + ".glb").instantiate()
			add_child(wall)
			wall.position.y = n * 0.3
			
func set_material(mat: Material) -> void:
	if get_child_count() > 0:
		for child in get_child(0).get_children():
			child.set_surface_override_material(0, mat)
