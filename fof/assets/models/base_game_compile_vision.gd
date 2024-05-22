extends Node3D
@onready var CheckCollision: RayCast3D = %CheckCollision
@onready var Search: LineEdit = %Search
@onready var ButtonContainer: VBoxContainer = %ButtonContainer
@onready var LoadedItem: Node3D = %LoadedItem
@onready var Camera: Camera3D = %Camera
@onready var CollisionPoints: Node3D = %CollisionPoints
@onready var label: Label = %Label

func _ready():
	const DIR_PATH: String = "res://assets/models/"
	for folder in ["decorations/tiles/", "decorations/walls/", "objects/", "tiles/", "walls/"]:
		var files: Array = Helper.return_file_names_recursive(DIR_PATH + folder).filter(func(x: String): return x.ends_with(".tscn"))
		for file in files:
			var btn := preload("res://assets/models/base_game_compile_vision_button.tscn").instantiate()
			btn.text = file.get_slice("/", file.get_slice_count("/") - 1).left(-5)
			btn.pressed.connect(onBtnPressed.bind(file))
			ButtonContainer.add_child(btn)

var copy_points: Array
var scene: Node3D
func onBtnPressed(file: String) -> void:
	onSave()
	if scene != null: scene.queue_free()
	scene = load(file).instantiate()
	LoadedItem.add_child(scene)
	for child in CollisionPoints.get_children(): child.queue_free()
	for point in scene.collision_points: onCreateCollisionPoint(point)
	label.text = file.get_slice("/", file.get_slice_count("/") - 1).left(-5)
	
func onSave() -> void:
	if scene != null:
		scene.collision_points = PackedVector3Array(CollisionPoints.get_children().map(func(x: Node3D): return x.position))
		var packed_scene := PackedScene.new()
		packed_scene.pack(scene)
		ResourceSaver.save(packed_scene, scene.scene_file_path)
	
func _on_search_text_changed(new_text):
	for btn in ButtonContainer.get_children():
		btn.visible = btn.text.begins_with(new_text)
		
func _input(_event: InputEvent) -> void:
	if Input.is_action_just_released("LeftClick"):
		CheckCollision.position = Camera.position
		CheckCollision.target_position = (Camera.project_ray_normal(get_viewport().get_mouse_position()) * 100) - CheckCollision.position
		CheckCollision.force_raycast_update()
		if CheckCollision.is_colliding():
			if CheckCollision.get_collider().get_parent() is MeshInstance3D:
				onCreateCollisionPoint(CheckCollision.get_collision_point())
			else: CheckCollision.get_collider().get_parent().queue_free()

func onCreateCollisionPoint(pos: Vector3) -> void:
	var collision_point: Node3D = preload("res://assets/models/collision_point.tscn").instantiate()
	collision_point.enabled = false
	collision_point.position = pos
	CollisionPoints.add_child(collision_point)

func onCopy():
	copy_points = CollisionPoints.get_children().map(func(x: Node3D): return x.position)
			
func onPaste():
	for child in CollisionPoints.get_children(): child.queue_free()
	for point in copy_points: onCreateCollisionPoint(point)

func onClear():
	for child in CollisionPoints.get_children(): child.queue_free()
