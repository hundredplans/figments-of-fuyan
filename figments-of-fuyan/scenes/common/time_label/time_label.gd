extends Label

var save_file: SaveFileGD
func setInfo(_save_file: SaveFileGD) -> void:
	save_file = _save_file

func _process(_delta: float) -> void:
	var time_elapsed: int = save_file.getTimeElapsed()
	var minutes: int = time_elapsed / 60
	var seconds: int = fmod(time_elapsed, 60)
	var time_string: String = "%02d:%02d" % [minutes, seconds]
	text = str(time_string)
