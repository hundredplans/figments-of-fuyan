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
	
	scene.mesh = scene.get_child(0)
	scene.body = scene.get_child(0).get_child(0)
	
	for key in FOLDER_NAME_BEGINS_WITH:
		if dir_path.begins_with(FOLDER_NAME_BEGINS_WITH[key]):
			scene.type = key
	
	for i in REMOVE_COLLISION:
		if scene.name.begins_with(i): scene.body.get_child(0).shape = null
		
	if FileAccess.file_exists(scene_path):
		var loaded_scene: Node = load(scene_path).instantiate()
		scene.collision_points = loaded_scene.collision_points
	
	scene.body.collision_layer = 24
	scene.body.collision_mask = 0
	
	var packed_scene := PackedScene.new()
	packed_scene.pack(scene)
	ResourceSaver.save(packed_scene, scene_path)
		
	return scene
