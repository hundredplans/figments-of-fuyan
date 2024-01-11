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
	
func on_spectate(type: String = "Unit", id: int = 0) -> void:
	var i: int = 0
	for tile in get_tiles():
		if type == "Spawn" and tile.tile_info.obj.id == 2:
			if i == id: 
				SpectateCamera.on_camera_start_spectate(tile.global_position)
				break
			i += 1
	add_to_history(["on_spectate", type, id])

func get_tiles() -> Array:
	return Tiles.get_children()

func add_to_history(history_info: Array) -> void:
	GameState.history.append(history_info)
