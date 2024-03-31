extends Node
@export var Model: PackedScene = null

func _ready() -> void:
	if Model == null:
		var file_paths: Array = []
		on_find_files(file_paths, "res://assets/base_game/cards")
		for file in file_paths.filter(func(x: String): return !FileAccess.file_exists(x.left(-4) + ".tscn")):
			# DONT REMOVE FILTER NO MATTER WHAT
			onCompileUnit(file)
	else:
		onCompileUnit(Model.resource_path)
	
func on_find_files(file_paths: Array, dir: String) -> void:
	for _dir in DirAccess.get_directories_at(dir):
		_dir = _dir.insert(0, "/")
		on_find_files(file_paths, dir + _dir)
		
	for file in DirAccess.get_files_at(dir):
		if file.ends_with(".glb"): file_paths.append(dir + "/" + file)

func onCompileUnit(file: String) -> void:
	var glb: Node3D = load(file).instantiate()
	glb.name = "Model"
	glb.script = preload("res://scenes/screens/level_map/utility_nodes/units/model.gd")
	if glb.get_child(0).has_node("Skeleton3D") and !glb.get_child(0).get_node("Skeleton3D").get_children().any(func(x: Node3D): return x is StaticBody3D):
		var static_body := StaticBody3D.new()
		static_body.collision_layer = 4
		static_body.collision_mask = 0
		static_body.position.y += 1
		
		glb.get_child(0).get_node("Skeleton3D").add_child(static_body)
		static_body.owner = glb
		
		var collision_shape := CollisionShape3D.new()
		collision_shape.shape = BoxShape3D.new()
		static_body.add_child(collision_shape)
		collision_shape.owner = glb
	
	await get_tree().create_timer(0.001).timeout
	print(file + " remember to resize their box!")
	var packed_scene := PackedScene.new()
	packed_scene.pack(glb)
	ResourceSaver.save(packed_scene, file.left(-4) + ".tscn")
