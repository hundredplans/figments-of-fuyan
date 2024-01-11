extends Node3D
var GameState: Node

var LoadedLevel: Node3D
var Tiles: Node3D
@onready var Units: Node3D = $Units
@onready var SpectateCamera: Camera3D = $SpectateCamera

func on_load_default_world_state() -> void:
	LoadedLevel = load("res://assets/base_game/levels/" + GameState.level_info.bgfn + "/loaded_level.tscn").instantiate()
	LoadedLevel.script = null
	Tiles = LoadedLevel.get_node("Tiles")
	
	add_child(LoadedLevel)
	on_spectate("Spawn")

func on_load_world_history() -> void:
	var history: Array = GameState.history.duplicate()
	GameState.history = []
	for event in history:
		pass
	
var spectate_type: String
var spectate_id: int = 0
func on_spectate(type: String = "Unit", id: int = 0) -> void:
	spectate_type = type
	spectate_id = id
	if type == "Spawn":
		var spawn_tiles: Array = get_tiles().filter(func(x: Node3D): return x.tile_info.obj.id == 2)
		
		if spectate_id == spawn_tiles.size(): spectate_id = 0
		elif spectate_id < 0: spectate_id = spawn_tiles.size() - 1
		
		SpectateCamera.on_camera_start_spectate(spawn_tiles[spectate_id].position)
	add_to_history(["on_spectate", type, id])

func on_select_spectate_camera_direction(i: int) -> void:
	spectate_id += i
	on_spectate(spectate_type, spectate_id)
	
func get_tiles() -> Array:
	return Tiles.get_children()

func add_to_history(history_info: Array) -> void:
	GameState.history.append(history_info)
