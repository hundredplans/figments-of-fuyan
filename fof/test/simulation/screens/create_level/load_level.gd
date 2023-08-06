extends Control
signal load_level

func _ready():
	theme = preload("res://test/simulation/assets/fonts/bad_theme.tres")
	var file_names: PackedStringArray = DirAccess.open("user://savefofle/levels").get_files()
	file_names = Array(file_names).filter(func(x: String): return x.ends_with(".txt"))
	
	for file in file_names:
		var btn := Button.new()
		btn.text = file
		btn.size = Vector2(200, 50)
		$LoadLevelButtons.add_child(btn)
		btn.pressed.connect(on_load_level.bind(btn.text))
		
		var rem_btn = Button.new()
		rem_btn.text = "  X  "
		rem_btn.position.x = 165
		rem_btn.pressed.connect(on_rem_btn_pressed.bind(file, btn))
		btn.add_child(rem_btn)
		
	var x: int = 0
	var y: int = 0
	for child in $LoadLevelButtons.get_children():
		child.position.x += x
		child.position.y += y
		x += 210
		if x >= 1680:
			x = 0
			y += 60
		
func _on_button_pressed():
	queue_free()

func on_load_level(level_name: String) -> void:
	load_level.emit(level_name)
	queue_free()

func on_rem_btn_pressed(file: String, card: Control):
	var dir := DirAccess.open("user://savefofle/levels")
	dir.remove(file)
	card.queue_free()
