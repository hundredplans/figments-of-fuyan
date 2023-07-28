extends Node2D
signal card_selected

func _ready():
	var file_names: PackedStringArray = DirAccess.open("user://save/cards").get_files()
	file_names = Array(file_names).filter(func(x: String): return x.ends_with(".txt"))
	
	for file in file_names:
		var card := Button.new()
		$LoadCardButtons.add_child(card)
		card.size = Vector2(200, 50)
		card.text = file
		card.pressed.connect(func(): card_selected.emit(file))

	var x: int = 0
	var y: int = 0
	for child in $LoadCardButtons.get_children():
		child.position.x += x
		child.position.y += y
		x += 210
		if x >= 1680:
			x = 0
			y += 60

func _on_button_pressed():
	queue_free()
