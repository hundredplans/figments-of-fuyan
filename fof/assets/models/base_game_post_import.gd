@tool
extends EditorScenePostImport

var REMOVE_COLLISION: Array = [
	"shrub",
	"coconut_floor",
	"palmrock",
	"spawn"
]

var FOLDER_NAME_BEGINS_WITH: Dictionary = {
	"tile": "res://assets/models/tiles/",
	"wall": "res://assets/models/walls/",
	"obj": "res://assets/models/objects/",
	"tdeco": "res://assets/models/decorations/tiles/",
	"wdeco": "res://assets/models/decorations/walls/"
}

func _post_import(scene: Node) -> Node:
	scene.script = preload("res://assets/models/model_type.gd")
	
	var scene_path: String = get_source_file().left(-4) + ".tscn"
	var dir_path: String = get_source_file()
	
	scene.meshes = []
	scene.bodies = []
	
	if FileAccess.file_exists(scene_path):
		var loaded_scene: Node = load(scene_path).instantiate()
		scene.collision_points = loaded_scene.collision_points
		scene.rotation_degrees = loaded_scene.rotation_degrees
		
		if !getChildrenRecursive(scene).any(func(x: Node): return x is StaticBody3D):
			var meshes: Array = getChildrenRecursive(scene).filter(func(x: Node): return x is MeshInstance3D)
			var _meshes: Array = getChildrenRecursive(loaded_scene).filter(func(x: Node): return x is MeshInstance3D)
			
			for i in range(meshes.size()):
				if _meshes[i].get_child_count() > 0:
					var _static_body: StaticBody3D = _meshes[i].get_child(0)
					var static_body := StaticBody3D.new()
					
					meshes[i].add_child(static_body)
					await static_body.ready
					static_body.owner = scene
					
					static_body.rotation = _static_body.rotation
					static_body.global_position = _static_body.global_position
					scene.bodies.append(static_body)
					
					for child_col in _static_body.get_children():
						var collision_shape := CollisionShape3D.new()
						
						static_body.add_child(collision_shape)
						await collision_shape.ready
						collision_shape.owner = scene
						
						collision_shape.shape = child_col.shape
						collision_shape.rotation = child_col.rotation
						collision_shape.global_position = child_col.global_position
						
	for child in getChildrenRecursive(scene):
		if child is MeshInstance3D: scene.meshes.append(child)
		elif child is StaticBody3D: scene.bodies.append(child)
	
	for key in FOLDER_NAME_BEGINS_WITH:
		if dir_path.begins_with(FOLDER_NAME_BEGINS_WITH[key]):
			scene.type = key
	
	for i in REMOVE_COLLISION:
		if scene.name.begins_with(i):
			for child in scene.bodies: child.get_child(0).shape = null
		
	for body in scene.bodies: body.collision_layer = 24; body.collision_mask = 0
	
	var packed_scene := PackedScene.new()
	packed_scene.pack(scene)
	ResourceSaver.save(packed_scene, scene_path)
	return scene

func getChildrenRecursive(node: Node, children := []):
	children.append(node)
	for child in node.get_children():
		children = getChildrenRecursive(child, children)
	return children

