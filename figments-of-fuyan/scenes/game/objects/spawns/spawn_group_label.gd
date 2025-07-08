extends Label3D

func setInfo(groups: Array) -> void:
	setGroups(groups)

func setGroups(groups: Array) -> void:
	if groups.is_empty(): text = ""; return
	groups = groups.duplicate()
	groups.sort_custom(func(x: String, y: String): return x < y)
	
	text = str(groups)
	text = text.replace("\"", "")
