@tool
extends EditorScenePostImport

func _post_import(scene: Node) -> Node:
	scene.name = "Model"
	scene.script = preload("res://scenes/screens/level_map/utility_nodes/units/model.gd")
	var scene_path: String = get_source_file().left(-4) + ".tscn"
	onCreateScene(scene)
	if FileAccess.file_exists(scene_path):
		var loaded_scene: Node = load(scene_path).instantiate()
		scene.collision_points = loaded_scene.collision_points
		
		var collision_shape: CollisionShape3D = loaded_scene.get_child(0).get_child(0).get_child(1).get_child(0)
		var scene_collision_shape: CollisionShape3D = scene.get_child(0).get_child(0).get_child(1).get_child(0)
		
		scene_collision_shape.shape = collision_shape.shape
		scene_collision_shape.shape.size = collision_shape.shape.size
		scene_collision_shape.position = collision_shape.position
	
	var packed_scene := PackedScene.new()
	packed_scene.pack(scene)
	ResourceSaver.save(packed_scene, scene_path)
	return scene

func onCreateScene(scene: Node) -> void:
	var static_body := StaticBody3D.new()
	static_body.collision_layer = 36
	static_body.collision_mask = 0
	static_body.position.y += 1
	
	scene.get_child(0).get_node("Skeleton3D").add_child(static_body)
	static_body.owner = scene
	
	var collision_shape := CollisionShape3D.new()
	collision_shape.shape = BoxShape3D.new()
	static_body.add_child(collision_shape)
	collision_shape.owner = scene
