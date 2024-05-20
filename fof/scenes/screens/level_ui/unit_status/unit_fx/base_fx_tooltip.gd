extends Control

func setTooltip(text: String) -> void:
	$Label.text = text

func setPosition() -> void:
	global_position = get_viewport().get_mouse_position() + Vector2(30, -43)
