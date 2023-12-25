extends Control

var info: Dictionary
func apply_info() -> void:
	$Label.text = info.sname
	$Background/Outside.color = Helper.task_accent_colors[info.difficulty]
	$Background/Inside.color = Helper.task_primary_colors[info.difficulty]
