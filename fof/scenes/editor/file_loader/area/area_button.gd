extends Control
var info: Dictionary
		
func apply_info() -> void:
	$Label.text = info.sname
	$World.text = "World " + str(info.world)
	$Background/Outside.color = info.pcolor
	$Background/Inside.color = info.acolor
