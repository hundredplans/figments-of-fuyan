extends Control

func setTooltip(text: String, charges: int) -> void:
	if charges != -1: text = text.replace("[X]", '[' + str(charges) + ']')
	$Label.text = text

func setPosition() -> void:
	global_position = get_viewport().get_mouse_position() + Vector2(30, -43)
