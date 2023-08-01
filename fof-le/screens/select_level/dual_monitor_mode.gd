extends Control

func _ready():
	get_parent().get_node("DualMonitorMode").queue_free()
#	ProjectSettings.set_setting("display/window/size/viewport_width", 3840)
#	ProjectSettings.set_setting("display/window/size/viewport_width", DisplayServer.WINDOW_MODE_WINDOWED)
	DisplayServer.window_set_size(Vector2i(3840, 1080), 0)
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED, 0)
