extends Control
signal pressed
var can_press: bool = false
var info: Dictionary
		
func set_info(_info: Dictionary) -> void:
	info = _info
	$Label.text = "World " + str(info.world) + "\n\n" + info.sname
	$ID.text = str(info.id)
	$Background/Outside.color = info.pcolor
	$Background/Inside.color = info.acolor

func _on_pressed_button_pressed():
	pressed.emit(self, info)
