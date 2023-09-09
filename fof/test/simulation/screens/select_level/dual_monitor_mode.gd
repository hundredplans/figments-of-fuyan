extends Control
var is_left: bool = false

func _ready():
	theme = preload("res://test/simulation/assets/fonts/roboto32.tres")
	DisplayServer.window_set_size(Vector2i(3840, 1080), 0)
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED, 0)
	get_parent().get_parent().get_node("Backgrounder").visible = true
