extends Node

var FOLDER_NAME_TO_TYPE: Dictionary = {
	"objects": "obj",
	"tiles": "tile",
	"walls": "wall",
}
func _ready() -> void:
	var file_paths: Array = []
	on_find_files(file_paths, "res://assets/models")
	for file in file_paths:
		var glb: Node3D = load(file).instantiate()
		add_child(glb)
		var folder_array: Array = file.split("/")
		var folder_name: String = ""
		for i in range(folder_array.size()):
			if i >= 4:
				folder_name += folder_array[i]
				if i != folder_array.size() - 1:
					folder_name += "/"
					
		var mesh: MeshInstance3D = glb.get_child(0)
		glb.script = preload("res://assets/models/model_type.gd")
		glb.mesh = mesh
		glb.type = FOLDER_NAME_TO_TYPE[folder_name.get_slice("/", 0)] if !folder_name.begins_with("decorations")\
		else ("tdeco" if folder_name.begins_with("decorations/tiles") else "wdeco")
		
		mesh.create_trimesh_collision()
		
		var body: StaticBody3D = mesh.get_child(0)
		glb.body = body
		
		body.collision_layer = 8 if folder_name.begins_with("tiles") else 10
		body.collision_mask = 0
		body.reparent(glb)
		body.owner = glb
		body.get_child(0).owner = glb
			
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
