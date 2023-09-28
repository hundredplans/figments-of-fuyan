extends Control
var info: Dictionary

func apply_info() -> void:
	$Card.set_info(info)
	$ID.text = str(info.id)
