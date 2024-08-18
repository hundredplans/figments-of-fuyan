extends Node3D

#region Exports
@export var black_environment: Environment
@export var base_environment: Environment
@export var ChampionSelectPacked: PackedScene
#endregion

#region Globals
signal begin_travel
signal end_travel

var UI: Control
var main_menu_mesh_name: String
@onready var env: WorldEnvironment = %WorldEnvironment
@onready var Camera: Camera3D = %Camera
@onready var MapModel: Node3D = %MapModel
@onready var ani_player: AnimationPlayer = $AnimationPlayer
@onready var map_light: Light3D = %DirectionalLight3D
#endregion

#region Base Functions
func _ready() -> void:
	ani_player.animation_finished.connect(onAnimationFinished)
	setMapLights(false)

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("Back"): onBack()
#endregion

#region Animation / Mesh Travelling
var travelling_mesh_name: String = ""

func onAnimationFinished(mesh_name: String) -> void:
	match travelling_mesh_name:
		"Gate": get_tree().quit()
		
	if travelling_mesh_name != "Gate":
		end_travel.emit(mesh_name, is_exit)
		travelling_mesh_name = ""
		if !is_exit: history.append(mesh_name)
		
	
func onMeshChosen(ani_name: String) -> void:
	if !ani_player.is_playing():
		is_exit = false
		travelling_mesh_name = ani_name
		ani_player.play(travelling_mesh_name)
		begin_travel.emit(travelling_mesh_name, is_exit)
#endregion
		
#region Back
var is_exit: bool = false
var history: Array = []
func onBack() -> void:
	if !ani_player.is_playing() and !history.is_empty():
		is_exit = true
		travelling_mesh_name = history.pop_back()
		ani_player.play_backwards(travelling_mesh_name)
		begin_travel.emit(travelling_mesh_name, is_exit)
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
		add_child(ChampionSelect)
	else: ChampionSelect.queue_free()
	
func setMapLights(is_enter: bool) -> void:
	env.environment = black_environment if is_enter else base_environment
	map_light.light_color = Color(0, 0, 0) if is_enter else Color(1, 1, 1)
#endregion
