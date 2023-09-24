extends Control

func set_info(info: Dictionary) -> void:
	$Label.text = "World " + str(info.world) + "\n\n" + info.iname
	$ID.text = info.id
	$Background/Outside.color = str_to_var("Color" + info.pcolor)
	$Background/Inside.color = str_to_var("Color" + info.acolor)
