extends Control
var info: Dictionary

func apply_info() -> void:
	$Label.text = info.sname
	$Background/Outside.color = Helper.rarity_accent_colors[info.r]
	$Background/Inside.color = Helper.rarity_colors[info.r]
