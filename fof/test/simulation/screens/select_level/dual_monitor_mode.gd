extends Control
var is_left: bool = false

func _ready():
	theme = preload("res://test/simulation/assets/fonts/roboto32.tres")
	get_parent().get_node("DualMonitorMode").queue_free()
	DisplayServer.window_set_size(Vector2i(3840, 1080), 0)
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED, 0)
	get_parent().get_parent().get_node("Backgrounder").visible = true
	for child in get_parent().get_node("Buttons").get_children():
		child.position.x += 1920
	move_map_related(1)

func _on_left_pressed():
	if !is_left: move_map_related(-1)
	is_left = true
	
func _on_right_pressed():
	if is_left: move_map_related(1)
	is_left = false

func move_map_related(multiplier: int):
	get_parent().get_node("Tiles").position.x += (1920 * multiplier)
	get_parent().get_node("ActiveArt").position.x += (1920 * multiplier)
