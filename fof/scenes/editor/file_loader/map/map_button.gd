extends Control
var info: Dictionary

func apply_info() -> void:
	$Label.text = info.sname
	$World.text = "World " + str(info.world)
