extends Control

const OFFSET: Vector2 = Vector2(30, -43)
func setInfo(text: String) -> void:
	$Label.text = text

func setPosition() -> void:
	global_position = get_viewport().get_mouse_position() + OFFSET
