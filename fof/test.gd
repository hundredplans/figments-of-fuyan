extends Node

func _ready() -> void:
	var arr: Array = ["decorations/", "objects/", "tiles/", "walls/"]
	for str in arr:
		for file_name in Helper.return_file_names_recursive("res://assets/models/" + str):
			if file_name.ends_with(".tscn"):
				var scene: Node3D = load(file_name).instantiate()
				for child in Helper.get_children_recursive(scene):
					if child is StaticBody3D: child.collision_layer = 24
				ResourceSaver.save(scene, file_name)
