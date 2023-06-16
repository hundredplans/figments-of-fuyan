extends Node

const start_map_load_name: String = "start_screen"
const start_gui_path: String = "res://screens/start_screen/start_screen_gui.tscn"

const lobby_map_name: String = "lobby_map"
const lobby_gui_path: String = "res://screens/lobby_map/lobby_map_gui.tscn"

func _ready():
	#$GameWorld.load_map(start_map_load_name)
	#$GUI.load_gui(start_gui_path)
	on_lobby_connected(5)

func on_lobby_connected(_id: int) -> void:
	$GUI.load_gui(lobby_gui_path)
	$GameWorld.load_lobby_map(lobby_map_name)
