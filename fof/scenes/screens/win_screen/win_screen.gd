extends Control

signal screen_change_sig
signal load_world
var GameState: Node

func _ready() -> void:
	load_world.emit(null)

func _on_continue_button_pressed():
	GameState.level_info = {"id": 0}
	screen_change_sig.emit("res://scenes/screens/map_menu/map_menu.tscn")
