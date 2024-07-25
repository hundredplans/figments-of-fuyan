extends Node3D

@export var Main: Node
func _ready():
	var dev := preload("res://static/dev/dev.tres")
	Helper.on_load_game_state(dev.auto_level_save_file)
	Main.on_menu_button_pressed("res://scenes/screens/level_ui/level_ui.tscn")
	
 
