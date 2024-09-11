extends Node3D

#region Exports
@export var black_environment: Environment
@export var base_environment: Environment
@export var ChampionSelectPacked: PackedScene
@export var START_GAME_FADE_OUT_TIME: float = 0.75
@export var CHAMPION_POSE_TRAVEL_TIME: float = 0.5
#endregion

#region Globals
signal champion_pressed
signal travel
signal start
signal create_ui

var UI: Control
@onready var env: WorldEnvironment = %WorldEnvironment
@onready var Camera: Camera3D = %Camera
@onready var MapModel: Node3D = %MapModel
@onready var ani_player: AnimationPlayer = $AnimationPlayer
@onready var map_light: Light3D = %DirectionalLight3D
@onready var spotlight: SpotLight3D = %SpotLight3D
#endregion

#region Helpers
func setUnitsPickable(state: bool) -> void:
	get_tree().call_group("CardsGD", "setRayPickable", state)
#endregion

#region Base Functions
func _ready() -> void:
	ani_player.animation_finished.connect(onAnimationFinished)
	setMapLights(false)
	UI.start.connect(onStart)
	UI.cancel_champion_selected.connect(onBack)

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("Back"): onBack()
#endregion

#region Animation / Mesh Travelling
var active_camera_item := CameraItem.new("MainMenu")
var active_travel_info: CameraTravelDatastore

func onFinishTravel() -> void:
	active_travel_info.is_start = false
	active_camera_item = active_travel_info.end
	travel.emit(active_travel_info)
	
	if !active_travel_info.is_history: history.append(active_travel_info)
	active_travel_info = null

func onAnimationFinished(__: String) -> void:
	match active_travel_info.end.name:
		"Gate": get_tree().quit()
		_: onFinishTravel()
		
func onMeshChosen(camera_item: CameraItem) -> void:
	if active_travel_info == null:
		if camera_item.menu != null:
			create_ui.emit(camera_item.menu)
		else:
			active_travel_info = CameraTravelDatastore.new(active_camera_item, camera_item, onAnimationTravel)
			active_travel_info.travel_callable.call()
#endregion
		
#region Back
var history: Array = []
func onBack() -> void:
	if active_travel_info == null and !history.is_empty():
		active_travel_info = history.pop_back()
		active_travel_info.end = active_travel_info.start
		active_travel_info.start = active_camera_item
		active_travel_info.is_start = true
		active_travel_info.is_history = true
		active_travel_info.travel_callable.call()
#endregion

#region NewGame
var ChampionSelect: Node3D
func onNewGameHideFrame() -> void:
	var is_enter: bool = ani_player.get_playing_speed() > 0
	setMapLights(is_enter)
	MapModel.onNewGameHideFrame(is_enter)
	
	Camera.setDisableFreelook(!is_enter)
	if is_enter:
		ChampionSelect = ChampionSelectPacked.instantiate()
		ChampionSelect.champion_pressed.connect(onChampionPressed)
		add_child(ChampionSelect)
	else: ChampionSelect.queue_free()
	
func setMapLights(is_enter: bool) -> void:
	env.environment = black_environment if is_enter else base_environment
	map_light.light_color = Color(0, 0, 0) if is_enter else Color(1, 1, 1)
	
func onChampionPressed(Card: CardGD) -> void:
	setUnitsPickable(false)
	active_travel_info = CameraTravelDatastore.new(active_camera_item, CameraItem.new("ChampionPressed"),\
	onChampionTweenTravel.bind(Card, PosRot.new(Camera.position, Camera.rotation_degrees)))
	active_travel_info.travel_callable.call()
	
func onStart(Card: CardGD) -> void:
	active_travel_info = CameraTravelDatastore.new(active_camera_item, CameraItem.new("StartGame"), onStartTravel.bind(Card))
	active_travel_info.travel_callable.call()
	
func onStartTravel(Card: CardGD) -> void:
	var rot_tween := get_tree().create_tween()
	rot_tween.tween_property(Camera, "rotation_degrees", Vector3(-90, 90, 0), START_GAME_FADE_OUT_TIME)
	
	var light_tween := get_tree().create_tween()
	light_tween.tween_property(spotlight, "light_color", Color(0, 0, 0), START_GAME_FADE_OUT_TIME)
	travel.emit(active_travel_info)
	await light_tween.finished
	start.emit(Card)
#endregion

#region Travelling
var is_travelling: bool = false
func onTravelStateChanged(travel_info: CameraTravelDatastore) -> void:
	is_travelling = travel_info.is_start
	
func onAnimationTravel() -> void:
	if !active_travel_info.is_history: ani_player.play(active_travel_info.end.name)
	else: ani_player.play_backwards(active_travel_info.start.name)
	travel.emit(active_travel_info)
	
func onChampionTweenTravel(Card: CardGD, camera_pos_rot: PosRot) -> void:
	var travel_posrot: PosRot = camera_pos_rot
	if !active_travel_info.is_history:
		var node := Node3D.new()
		Card.add_child(node)
		node.position = Card.info.champion_select_posrot.pos
		
		var posrot := PosRot.new(node.global_position, Card.info.champion_select_posrot.rot)
		posrot.rot.y += node.global_rotation_degrees.y
		node.queue_free()
		travel_posrot = posrot
	
	var pos_tween := get_tree().create_tween()
	pos_tween.tween_property(Camera, "position", travel_posrot.pos, CHAMPION_POSE_TRAVEL_TIME)
	
	var rot_tween := get_tree().create_tween()
	rot_tween.tween_property(Camera, "rotation_degrees", travel_posrot.rot, CHAMPION_POSE_TRAVEL_TIME)
		
	travel.emit(active_travel_info)
	
	await pos_tween.finished
	if !active_travel_info.is_history: champion_pressed.emit(Card)
	else: setUnitsPickable(true)
	onFinishTravel()
#endregion
