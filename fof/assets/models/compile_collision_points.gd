extends Node3D

@export var packed_object: PackedScene
var TileObject: Node3D

var collision_object_points: Array
@onready var CollisionPoints: Node3D = %CollisionPoints
@onready var PointRaycast: RayCast3D = %PointRaycast
@onready var Camera: Camera3D = $Camera3D

func onInstantiatePackedObject() -> void:
	TileObject = packed_object.instantiate()
	add_child(TileObject)
	collision_object_points = Array(TileObject.collision_points.duplicate())
	
	for point in TileObject.collision_points:
		onGenerateCollisionPoint(point)

func _ready() -> void:
	Camera.current = true
	if get_parent() == get_tree().get_root():
		onInstantiatePackedObject()

func onGenerateCollisionPoint(point: Vector3) -> void: # Creates the 3D effect of point, doesn't add to collision_object_points
	pass
	#var CollisionPoint: Node3D = preload("res://assets/models/collision_point.tscn").instantiate()
	#CollisionPoint.position = point
	#CollisionPoint.point = point
	#CollisionPoint.remove_collision_point.connect(onRemoveCollisionPoint)
	#CollisionPoints.add_child(CollisionPoint)
	#
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
	ResourceSaver.save(packed_scene, TileObject.scene_file_path)
