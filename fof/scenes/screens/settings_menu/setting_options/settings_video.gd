extends Control
const setting: String = "Video"

func _ready():
	for info in Settings.settings_info[setting]:
		match info[0]:
			"FPS": $FPS/Button.select(info[1])
			"WindowMode": $WindowMode/Button.select(info[1])
			"Resolution": $Resolution/Button.select(info[1])
			"VSync": $VSync/Button.select(info[1])

	for child in get_children().map(func(x: Control): return x.get_node("Button")):
		if child is OptionButton:
			child.item_selected.connect(Settings["set_" + child.get_parent().name.to_lower()])
			child.item_selected.connect(Settings.update_settings_info.bind(setting, child.get_parent().name))
