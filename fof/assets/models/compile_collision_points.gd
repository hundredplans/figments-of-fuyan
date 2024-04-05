extends Node3D

var FOLDER_NAME_TO_TYPE: Dictionary = {
	"objects": "obj",
	"tiles": "tile",
	"walls": "wall",
}

@export var packed_object: PackedScene
var TileObject: Node3D

var collision_object_points: Array
@onready var CollisionPoints: Node3D = %CollisionPoints
@onready var PointRaycast: RayCast3D = %PointRaycast
@onready var Camera: Camera3D = $Camera3D

func onInstantiatePackedObject() -> void:
	TileObject = packed_object.instantiate()
	add_child(TileObject)
	onCreateStaticBody()
	collision_object_points = Array(TileObject.collision_points.duplicate())
	
	for point in TileObject.collision_points:
		onGenerateCollisionPoint(point)

func onCreateStaticBody() -> void:
	if TileObject.scene_file_path.begins_with("res://assets/models/") and\
	TileObject.scene_file_path.ends_with(".glb"):
		var folder_array: Array = TileObject.scene_file_path.split("/")
		var folder_name: String = ""
		for i in range(folder_array.size()):
			if i >= 4:
				folder_name += folder_array[i]
				if i != folder_array.size() - 1:
					folder_name += "/"
					
		var mesh: MeshInstance3D = TileObject.get_child(0)
		
		TileObject.script = preload("res://assets/models/model_type.gd")
		TileObject.mesh = mesh
		TileObject.type = FOLDER_NAME_TO_TYPE[folder_name.get_slice("/", 0)] if !folder_name.begins_with("decorations")\
		else ("tdeco" if folder_name.begins_with("decorations/tiles") else "wdeco")
		
		mesh.create_trimesh_collision()
		
		var body: StaticBody3D = mesh.get_child(0)
		TileObject.body = body
		
		body.collision_layer = 8 if folder_name.begins_with("tiles") else 10
		body.collision_mask = 0
		body.reparent(TileObject)
		body.owner = TileObject
		body.get_child(0).owner = TileObject
	

func _ready() -> void:
	Camera.current = true
	if get_parent() == get_tree().get_root():
		onInstantiatePackedObject()

func onGenerateCollisionPoint(point: Vector3) -> void: # Creates the 3D effect of point, doesn't add to collision_object_points
	var CollisionPoint: Node3D = preload("res://assets/models/collision_point.tscn").instantiate()
	CollisionPoint.position = point
	CollisionPoint.point = point
	CollisionPoint.remove_collision_point.connect(onRemoveCollisionPoint)
	CollisionPoints.add_child(CollisionPoint)
	
var is_removed: bool = false
func onRemoveCollisionPoint(point: Vector3) -> void:
	collision_object_points.erase(point)
	is_removed = true
	await get_tree().create_timer(0.05).timeout
	is_removed = false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("LeftClick") and !is_removed:
		onCastPointRaycast()

func onCastPointRaycast() -> void:
	PointRaycast.position = Camera.position
	PointRaycast.target_position = (Camera.project_ray_normal(get_viewport().get_mouse_position()) * 100) - PointRaycast.position
	PointRaycast.force_raycast_update()
	if PointRaycast.is_colliding():
		var collision_point: Vector3 = PointRaycast.get_collision_point()
		collision_object_points.append(collision_point)
		onGenerateCollisionPoint(collision_point)

func _on_save_button_pressed():
	TileObject.collision_points = PackedVector3Array(collision_object_points)
	var packed_scene := PackedScene.new()
	packed_scene.pack(TileObject)
	
	var new_path: String = TileObject.scene_file_path
	if TileObject.scene_file_path.ends_with(".glb"): new_path = new_path.left(-4) + ".tscn"
	ResourceSaver.save(packed_scene, new_path)
