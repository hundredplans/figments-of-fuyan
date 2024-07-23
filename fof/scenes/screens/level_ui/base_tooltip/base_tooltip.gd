extends Control

var OFFSET: Vector2 = Vector2(30, -43)
func setInfo(text: String) -> void:
	$Label.text = text
	if global_position.y < 50: OFFSET.y += 50
	if global_position.x > 1700: OFFSET.x -= (size.x + 50)


func setPosition() -> void:
	global_position = get_viewport().get_mouse_position() + OFFSET
