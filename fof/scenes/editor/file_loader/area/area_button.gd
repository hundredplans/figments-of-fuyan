extends Control
var info: Dictionary
		
func apply_info() -> void:
	$Label.text = "World " + str(info.world) + "\n\n" + info.sname
	$Background/Outside.color = info.pcolor
	$Background/Inside.color = info.acolor
