extends Node

func _ready() -> void:
	var file_paths: Array = []
	on_find_files(file_paths, "res://assets/models")
	for file in file_paths:
		var glb: Node3D = load(file).instantiate()
		add_child(glb)
		var folder_name: String = file.get_slice("/", 4)
		for child in glb.get_children():
			child.create_trimesh_collision()
			
			var static_body: StaticBody3D = child.get_child(0)
			static_body.collision_layer = 8 if folder_name != "tiles" else 10
			static_body.collision_mask = 0
			#static_body.disable_mode
			static_body.owner = glb
			static_body.get_child(0).owner = glb
			
		await get_tree().create_timer(0.001).timeout
		print(glb.name)
		var packed_scene := PackedScene.new()
		packed_scene.pack(glb)
		ResourceSaver.save(packed_scene, file.left(-4) + ".tscn")

func on_find_files(file_paths: Array, dir: String) -> void:
	for _dir in DirAccess.get_directories_at(dir):
		_dir = _dir.insert(0, "/")
		on_find_files(file_paths, dir + _dir)
		
	for file in DirAccess.get_files_at(dir):
		if file.ends_with(".glb"): file_paths.append(dir + "/" + file)
