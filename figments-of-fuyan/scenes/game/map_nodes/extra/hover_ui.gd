class_name HoverUI extends Control

func setMouseCenter(mouse_position: Vector2) -> void:
	global_position = mouse_position - (size / 2) - Vector2(0, 100)
	global_position.x = clamp(global_position.x, 0, get_viewport().size.x - size.x - 10)
	global_position.y = clamp(global_position.y, 0, get_viewport().size.y - size.y - 10)
	
func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		setMouseCenter(get_viewport().get_mouse_position())

func _process(_delta: float) -> void:
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED: queue_free()
