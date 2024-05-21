extends Control

@onready var WeaponControl: Control = %WeaponControl
@onready var EyeControl: Control = %EyeControl
@onready var TopControl: Control = %TopControl
@onready var StatControl: Control = %StatControl

@onready var StatArrow: Node3D = %StatArrow
@onready var WeaponOffset: Control = %WeaponOffset
@onready var WeaponArrow: Node3D = %WeaponArrow
@onready var EyeArrow: Node3D = %EyeArrow
@onready var TopArrow: Node3D = %TopArrow
@onready var Camera: Camera3D = %ModelCamera

@onready var ModelControls: Control = %ModelControls

var _Roboto20: Theme = preload("res://assets/UI/roboto/roboto12.tres")
var model_path: String
var base_card: BaseCardGD
func onCreateModel(_base_card: BaseCardGD) -> void:
	base_card = _base_card
	if !base_card.resource_path.is_empty():
		model_path = "res://assets/base_game/cards/cards/" + base_card.folder_name + "/model.glb"
		for child in ModelWorld.get_node("Model").get_children():
			child.queue_free()
			
		if FileAccess.file_exists(model_path):
			var model: Node3D = load(model_path).instantiate()
			ModelWorld.get_node("Model").add_child(model)
			
			for button in ModelControls.get_children(): button.queue_free()
			if model.has_node("AnimationPlayer"):
				var ani_player: AnimationPlayer = model.get_node("AnimationPlayer")
				for ani in ani_player.get_animation_library("").get_animation_list():
					var btn := Button.new()
					btn.text = ani
					btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
					btn.theme = _Roboto20
					btn.pressed.connect(on_play_model_animation.bind(ani_player, ani))
					
					if ani == "Attack": btn.pressed.connect(onAttackAnimationPlayed)
					ModelControls.add_child(btn)
			onSetHeights()
		
func onSetHeights():
	EyeArrow.position.y = base_card.eye
	TopArrow.position.y = base_card.top
	WeaponArrow.position.y = base_card.weapon
	WeaponOffset.text = str(base_card.weapon_offset)
	StatArrow.position.y = base_card.stat
	
	on_set_inital_height_controls()
		
func on_height_control_inactive() -> void: ActiveHeightControl = []
	
var ActiveHeightControl: Array = []
func on_move_height_control(HeightControl: Control, Arrow: Node3D) -> void:
	ActiveHeightControl = [HeightControl, Arrow]

var DEFAULT_HEIGHT_CONTROL_OFFSET: Vector2 = Vector2(0, -20)
func on_set_inital_height_controls() -> void:
	for i in range(height_controls.size()):
		height_controls[i].global_position.y = Camera.unproject_position(height_arrows[i].global_position).y
		height_controls[i].global_position += DEFAULT_HEIGHT_CONTROL_OFFSET
		height_controls[i].HeightLabel.text = str(snapped(height_arrows[i].position.y, 0.01))

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("RightClick"): 
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		get_viewport().update_mouse_cursor_state()
		
	if Input.is_action_just_released("RightClick"): Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
@onready var ModelWorld: Node3D = %ModelWorld
func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if Input.is_action_pressed("RightClick"):
			ModelWorld.get_node("Model").rotation_degrees.y += event.relative.x
		elif !ActiveHeightControl.is_empty(): 
			on_align_height_control(ActiveHeightControl[0], ActiveHeightControl[1], event.relative.y)

	if Input.is_action_just_pressed("MouseMiddle") and is_mouse_inside:
		add_child(preload("res://scenes/screens/card_editor/model_area_marker.tscn").instantiate())

func on_align_height_control(HeightControl: Control, Arrow: Node3D, y_offset: float) -> void:
	HeightControl.position.y += y_offset
	Arrow.position.y = Camera.project_position(HeightControl.global_position + Vector2(0, -260), 3).y
	HeightControl.HeightLabel.text = str(snapped(Arrow.position.y, 0.01))
	
@export var Y_GHOST_OFFSET: int = -260

var height_arrows: Array = []
var height_controls: Array = []

func _ready() -> void:
	height_arrows = [EyeArrow, TopArrow, WeaponArrow, StatArrow]
	height_controls = [EyeControl, TopControl, WeaponControl, StatControl]
	on_set_inital_height_controls()
	for i in range(height_controls.size()):
		height_controls[i].GrabButton.button_down.connect(on_move_height_control.bind(height_controls[i], height_arrows[i]))
		height_controls[i].GrabButton.button_up.connect(on_height_control_inactive)

func onAttackAnimationPlayed() -> void:
	var offset: float = float(WeaponOffset.text)
	var pos: float = float(WeaponControl.HeightLabel.text)
	if offset > 0.03:
		var planes: Array = []
		for i in range(2):
			var csg := CSGSphere3D.new()
			csg.radius = 0.05
			
			ModelWorld.add_child(csg)
			csg.material = preload("res://assets/materials/on_top.tres")
			planes.append(csg)
			
			csg.position.y = offset + pos if i == 0 else -offset + pos
			csg.position.x -= 1.2
			
		await get_tree().create_timer(3).timeout
		for plane in planes:
			plane.queue_free()

func on_play_model_animation(ani_player: AnimationPlayer, ani: String) -> void:
	ani_player.play(ani)

var is_mouse_inside: bool = false
func _on_mouse_entered(): is_mouse_inside = true
func _on_mouse_exited(): is_mouse_inside = false
