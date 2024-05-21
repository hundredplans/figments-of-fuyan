@tool
extends EditorScenePostImport

func _post_import(scene: Node) -> Node:
	scene.name = "Model"
	scene.script = preload("res://scenes/screens/level_map/utility_nodes/units/model.gd")
	var scene_path: String = get_source_file().left(-4) + ".tscn"
	if scene.get_child(0).has_node("Skeleton3D") and !FileAccess.file_exists(scene_path):
		onCreateScene(scene)
		var packed_scene := PackedScene.new()
		packed_scene.pack(scene)
		ResourceSaver.save(packed_scene, scene_path)
	return scene

func onCreateScene(scene: Node) -> void:
	var static_body := StaticBody3D.new()
	static_body.collision_layer = 4
	static_body.collision_mask = 0
	static_body.position.y += 1
	
	scene.get_child(0).get_node("Skeleton3D").add_child(static_body)
	static_body.owner = scene
	
	var collision_shape := CollisionShape3D.new()
	collision_shape.shape = BoxShape3D.new()
	static_body.add_child(collision_shape)
	collision_shape.owner = scene
