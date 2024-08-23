@tool
extends EditorScenePostImport

var REMOVE_COLLISION: Array = [
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
		
	for child in getChildrenRecursive(scene):
		if child is MeshInstance3D:
			scene.meshes.append(child)
			child.mesh.owner
			child.mesh.surface_set_material(0, preload("res://assets/materials/base_materials/base_material.tres"))
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
