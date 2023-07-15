extends Node

const start_map_load_name: String = "start_screen"
const start_gui_path: String = "res://screens/start_screen/start_screen_gui.tscn"

const lobby_map_name: String = "lobby_map"
const lobby_gui_path: String = "res://screens/lobby_map/lobby_map_gui.tscn"

func _ready():
	#$GameWorld.load_map(start_map_load_name)
	#$GUI.load_gui(start_gui_path)
	
	$GameWorld.add_to_back_history.connect(add_to_back_history)
	$GameWorld.change_animation_status.connect(change_animation_status)
	$GameWorld.lobby_camera_travel_main_menu_finished.connect(on_lobby_camera_travel_main_menu_finished)
	$GameWorld.lobby_camera_travel_item_finished.connect(on_lobby_camera_travel_item_finished)
	$GameWorld.lobby_camera_travel_item_started.connect(on_lobby_camera_travel_item_started)
	
	$GUI.lobby_item_selected.connect(on_lobby_item_selected)
	$GUI.exit_door_exit_game.connect(on_exit_door_exit_game)
	
	on_lobby_connected(5)
func on_lobby_connected(_id: int) -> void:
	$GUI.load_lobby_gui(lobby_gui_path)
	$GameWorld.load_lobby_map(lobby_map_name)
func on_lobby_camera_travel_item_started(item_id: int, direction: bool):
	$GUI.on_lobby_camera_travel_item_started(item_id, direction)
func add_to_back_history(item: Array):
	$GUI.add_to_back_history(item)
func change_animation_status(status: int):
	$GUI.change_animation_status(status)
func on_lobby_item_selected(item_id: int):
	$GameWorld.on_lobby_item_selected(item_id)
func on_lobby_camera_travel_main_menu_finished():
	$GUI.on_lobby_camera_travel_main_menu_finished()
func on_lobby_camera_travel_item_finished(path: String):
	$GUI.on_lobby_camera_travel_item_finished(path)
func on_exit_door_exit_game(path: String):
	$GameWorld.on_exit_door_exit_game(path)

