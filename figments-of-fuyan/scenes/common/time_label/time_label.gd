extends Label



var save_file: SaveFileGD
func _ready() -> void:
	save_file = Game.getSaveFile()
	
func _process(_delta: float) -> void:
	var time_elapsed: int = save_file.getTimeElapsed()
	var minutes: int = int(time_elapsed / 60.0)
	var seconds: int = int(fmod(time_elapsed, 60))
	var time_string: String = "%02d:%02d" % [minutes, seconds]
	text = str(time_string)

	match time_string.length():
		5: custom_minimum_size.x = 64
		6: custom_minimum_size.x = 78
		7: custom_minimum_size.x = 92
		_: custom_minimum_size.x = 64
		
