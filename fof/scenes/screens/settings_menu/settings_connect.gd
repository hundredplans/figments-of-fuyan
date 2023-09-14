extends Control
var setting: String

func _enter_tree(): # Important it's this
	for info in Settings.settings_info[setting]:
		if has_node(info[0]): get_node(info[0]).default = info[1]
		else: print_debug("The setting node is non-existent")

	for child in get_children():
		if !(child is Label):
			child.item_selected.connect(Settings["set_" + child.name.to_lower()])
			child.item_selected.connect(Settings.update_settings_info.bind(setting, child.name))
