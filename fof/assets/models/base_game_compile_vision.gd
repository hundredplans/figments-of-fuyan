extends Node3D
@onready var CheckCollision: RayCast3D = %CheckCollision
@onready var Search: LineEdit = %Search
@onready var ButtonContainer: VBoxContainer = %ButtonContainer
@onready var LoadedItem: Node3D = %LoadedItem
@onready var Camera: Camera3D = %Camera
@onready var CollisionPoints: Node3D = %CollisionPoints
@onready var label: Label = %Label
@onready var AnimationButtons: HBoxContainer = %AnimationButtons

func _ready():
	const DIR_PATH: String = "res://assets/models/"
	const UNIT_DIR_PATH: String = "res://assets/base_game/cards/cards/"
	for folder in DirAccess.get_directories_at(UNIT_DIR_PATH):
		var path: String = UNIT_DIR_PATH + folder + "/model.tscn"
		if FileAccess.file_exists(path):
			onCreateButton(path)
	
	for folder in ["decorations/tiles/", "decorations/walls/", "objects/", "tiles/", "walls/"]:
		var files: Array = Helper.return_file_names_recursive(DIR_PATH + folder).filter(func(x: String): return x.ends_with(".tscn"))
		for file in files: onCreateButton(file)
			
func onCreateButton(file: String) -> void:
	var btn := preload("res://assets/models/base_game_compile_vision_button.tscn").instantiate()
	var text: String = ""
	if file.ends_with("model.tscn"): text = file.get_slice("/", file.get_slice_count("/") - 2)
	else: text = file.get_slice("/", file.get_slice_count("/") - 1).left(-5)
	btn.text = text
	btn.pressed.connect(onBtnPressed.bind(file))
	ButtonContainer.add_child(btn)

var copy_points: Array
var scene: Node3D
var file_path: String
func onBtnPressed(file: String) -> void:
	onSave()
	file_path = file
	if scene != null: scene.queue_free()
	scene = load(file).instantiate()
	LoadedItem.add_child(scene)
	for child in CollisionPoints.get_children(): child.queue_free()
	for point in scene.collision_points: onCreateCollisionPoint(point)
	var text: String = ""
	var is_model: bool = file.ends_with("model.tscn")
	for child in AnimationButtons.get_children(): child.queue_free()
	if is_model: 
		text = file.get_slice("/", file.get_slice_count("/") - 2)
		for ani in scene.get_node("AnimationPlayer").get_animation_library("").get_animation_list():
			var btn := Button.new()
			btn.text = ani
			btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			btn.pressed.connect(onPlayModelAnimation.bind(scene.get_node("AnimationPlayer"), ani))
			AnimationButtons.add_child(btn)
	else:
		text = file.get_slice("/", file.get_slice_count("/") - 1).left(-5)
	
	label.text = text
	
func onPlayModelAnimation(AniPlayer: AnimationPlayer, ani: String) -> void:
	AniPlayer.play(ani)
	
func onSave() -> void:
	if scene != null:
		scene.collision_points = PackedVector3Array(CollisionPoints.get_children().map(func(x: Node3D): return x.position))
		var packed_scene := PackedScene.new()
		packed_scene.pack(scene)
		ResourceSaver.save(packed_scene, file_path)
	
func _on_search_text_changed(new_text):
	for btn in ButtonContainer.get_children():
		btn.visible = btn.text.begins_with(new_text)
		
func _input(_event: InputEvent) -> void:
	if Input.is_action_just_released("LeftClick"):
		CheckCollision.position = Camera.global_position
		CheckCollision.target_position = (Camera.project_ray_normal(get_viewport().get_mouse_position()) * 1000) - CheckCollision.position
		CheckCollision.force_raycast_update()
		if CheckCollision.is_colliding():
			var collider_parent: Node = CheckCollision.get_collider().get_parent()
			if collider_parent is MeshInstance3D or collider_parent is Skeleton3D:
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

func _on_mirror_pressed():
	for point in CollisionPoints.get_children().map(func(x: Node3D): return x.position):
		onCreateCollisionPoint(Vector3(point.x, point.y, -point.z))
