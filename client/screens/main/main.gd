extends Node

var start_map_load_name: String = "start_screen"
var start_gui_path: String = "res://screens/start_screen/start_screen_gui.tscn"

func _ready():
	$game_world.load_map(start_map_load_name)
	$gui.load_gui(start_gui_path)

func on_lobby_connected() -> void: pass
