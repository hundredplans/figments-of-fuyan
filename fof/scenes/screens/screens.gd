extends Control
@onready var main_menu: Control = $MainMenu

func _ready():
	main_menu.play_pressed.connect(on_play_pressed)
	
func on_play_pressed(): pass
