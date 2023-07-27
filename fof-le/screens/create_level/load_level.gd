extends Node2D
signal load_level

func _ready():
	var i: int = 0
	while FileAccess.file_exists("res://data/save/levels/%s.txt" % i):
		i += 1
	
	var x: int = 0
	var y: int = 0
	for j in range(i):
		var btn := Button.new()
		btn.text = str(j)
		btn.size = Vector2(50, 50)
		btn.position.x += x
		btn.position.y += y
		x += 60
		if x >= 360:
			x = 0
			y += 60
			
		$LoadLevelButtons.add_child(btn)
		btn.pressed.connect(on_load_level.bind(btn.text))
		
func _on_button_pressed():
	queue_free()

func on_load_level(level_name: String) -> void:
	load_level.emit(level_name)
