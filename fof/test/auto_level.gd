extends Node3D

@export var Main: Node
func _ready():
	Helper.on_load_game_state(2)
	Main.on_menu_button_pressed("res://scenes/screens/level_ui/level_ui.tscn")
	
	
