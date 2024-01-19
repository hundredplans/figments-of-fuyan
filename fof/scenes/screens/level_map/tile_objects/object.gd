extends Node3D
var type: String = "obj"
func on_load_info(info: Dictionary, area: int) -> void:
	for child in get_children(): child.queue_free()
	
	var obj_decoration_name: String = Helper.editor_id_to(1, info.id, info.type)
	rotation_degrees.y = info.rotation * 60
	
	match obj_decoration_name:
		"null", "spawns/spawn_ally", "spawns/spawn_trinket": pass
		"spawns/spawn_enemy", "spawns/spawn_neutral":
			if info.obj_info.size() > 0 and info.obj_info[0] in Helper.id_to_dict(area, "Area").cards:
				var card: Dictionary = Helper.id_to_dict(info.obj_info[0], "Card")
				var model_path: String = "res://assets/base_game/cards/card_ui/default_model.glb"
				var card_model_path: String = "res://assets/base_game/cards/" + card.bgfn + "/model.glb"
				if FileAccess.file_exists(card_model_path):
					model_path = card_model_path
				add_child(load(model_path).instantiate())
		_: add_child(load("res://assets/models/objects/" + obj_decoration_name + ".glb").instantiate())
		
