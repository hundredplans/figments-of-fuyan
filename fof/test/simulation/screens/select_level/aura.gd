extends Control

func load_aura(contents: Array) -> void:
	$Name.text = contents[0]
	$Text.text = contents[1]
	if FileAccess.file_exists(contents[2]): $ArtMax.texture = load(contents[2])
	match int(contents[3]):
		0: $Inside.color = Color(0.43,0.43,0.43,1)
		1: $Inside.color = Color(0.31, 0.478, 0.439,1)
		2: $Inside.color = Color(0.966, 0.697, 0.253,1)
		3: $Inside.color = Color(0.639, 0.075, 0.722,1)
		4: $Inside.color = Color(0.773, 0.031, 0.141, 1)
		5: $Inside.color = Color(0.374, 0.6, 1, 1)


func _on_destroy_button_pressed(): queue_free()
