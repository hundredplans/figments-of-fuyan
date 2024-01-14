extends GameObject
var GameState: Node

var LoadedLevel: Node3D
var Tiles: Node3D
var LevelUI: Control

@onready var Vision: Node3D = $Vision
@onready var History: Node = $History
@onready var Units: Node3D = $Units
@onready var SpectateCamera: Camera3D = $SpectateCamera

func on_set_utility_nodes_paths() -> void:
	SpectateCamera.History = History
	SpectateCamera.Tiles = Tiles
	Vision.Tiles = Tiles
	Vision.GameState = GameState
	History.GameState = GameState

func _ready() -> void:
	on_load_default_world_state()
	History.on_load_world_history()
	Vision.on_recalculate_vision()

func on_load_default_world_state() -> void:
	LoadedLevel = load("res://assets/base_game/levels/" + GameState.level_info.bgfn + "/loaded_level.tscn").instantiate()
	LoadedLevel.script = null
	
	Tiles = LoadedLevel.get_node("Tiles")
	Tiles.script = preload("res://scenes/screens/level_map/utility_nodes/tiles/tiles.gd")
	
	on_set_utility_nodes_paths()
	
	add_child(LoadedLevel)
	SpectateCamera.on_spectate("Spawn")
