extends Control
var info: Dictionary

func apply_info() -> void:
	var label_text: String = "Area " + str(info.area) + "\n"
	var area_info: Dictionary = Helper.id_to_dict(info.area, "Area")
	if area_info:
		label_text += area_info.sname
		$Background/Outside.color = area_info.pcolor
		$Background/Inside.color = area_info.acolor
	$Label.text = label_text + "\n" + info.sname
