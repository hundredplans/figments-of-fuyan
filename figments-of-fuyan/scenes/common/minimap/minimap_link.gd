extends Sprite2D

func setInfo(map_link: MapLink) -> void:
	if map_link.is_finished: modulate = Color(1, 1, 1, 0.2)
	elif map_link.is_holy: modulate = Color(1, 1, 1, 1)
