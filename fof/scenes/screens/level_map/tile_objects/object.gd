extends Node3D
var type: String = "obj"
func on_load_info(info: Dictionary, area: int) -> void:
	for child in get_children(): child.queue_free()
	
	var obj_decoration_name: String = Helper.editor_id_to(1, info.id, info.type)
	rotation_degrees.y = info.rotation * 60
	
	match obj_decoration_name:
		"null", "spawns/spawn_ally", "spawns/spawn_trinket", "spawns/spawn_enemy", "spawns/spawn_neutral": pass
		_: add_child(load("res://assets/models/objects/" + obj_decoration_name + ".glb").instantiate())
