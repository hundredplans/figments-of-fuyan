extends Control
signal card_selected

func _ready():
	theme = preload("res://test/simulation/assets/fonts/bad_theme.tres")
	var file_names: PackedStringArray = DirAccess.open("user://savefofle/cards").get_files()
	file_names = Array(file_names).filter(func(x: String): return x.ends_with(".txt"))
	
	for file in file_names:
		var card := Button.new()
		$LoadCardButtons.add_child(card)
		
		var rem_btn = Button.new()
		rem_btn.text = "  X  "
		rem_btn.position.x = 165
		rem_btn.pressed.connect(on_rem_btn_pressed.bind(file, card))
		
		card.add_child(rem_btn)
		
		card.size = Vector2(200, 50)
		card.pressed.connect(func(): card_selected.emit(file))
		
		var nfile := FileAccess.open("user://savefofle/cards/%s" % file, FileAccess.READ)
		var card_info: Array = nfile.get_as_text().split("\n")
		var rarity: int = 0
		card.text = str(card_info[6]) + " | " + file.left(-4)
		if card_info.size() > 7: rarity = int(card_info[7])
		
		match rarity:
			0: rem_btn.modulate = Color(0.43,0.43,0.43,1)
			1: rem_btn.modulate = Color(0.31, 0.478, 0.439,1)
			2: rem_btn.modulate = Color(0.966, 0.697, 0.253,1)
			3: rem_btn.modulate = Color(0.639, 0.075, 0.722,1)
			4: rem_btn.modulate = Color(0.773, 0.031, 0.141,1)
			5: rem_btn.modulate = Color(0.374, 0.6, 1, 1)

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

func on_rem_btn_pressed(file: String, card: Control):
	var dir := DirAccess.open("user://savefofle/cards")
	dir.remove(file)
	card.queue_free()
