extends Control

const SCROLL_SPEED: int = 40
var max_bottom: int = 0
var setting: String

func _ready() -> void:
	set_max_bottom()

func _enter_tree(): # Important it's this
	for info in Settings.settings_info[setting]:
		if has_node(info[0]): get_node(info[0]).default = info[1]
		else: print_debug("The setting node is non-existent")
		
	for child in get_children():
		if !(child is Label):
			child.item_selected.connect(Settings["set_" + child.name.to_lower()])
			child.item_selected.connect(Settings.update_settings_info.bind(setting, child.name))
			if child.scene_file_path.ends_with("mc_button.tscn"):
				child.change_open_state.connect(on_mc_button_change_open_state.bind(child))
				
func set_max_bottom() -> void:
	max_bottom = 0
	for child in get_children():
		var max_position: int = child.position.y + child.size.y - size.y
		if max_position > max_bottom:
			max_bottom = max_position
				
func on_mc_button_change_open_state(open_state: bool, mc_button: Control) -> void:
	var i: int = 1 if open_state else -1
	for child in get_children():
		if child != mc_button and child.global_position.y > mc_button.global_position.y:
			child.position.y += mc_button.max_size * i
	set_max_bottom()
	scroll_settings(0)

func _process(_delta: float) -> void:
	for i in [["MouseDown", -1], ["MouseUp", 1]]:
		if Input.is_action_just_pressed(i[0]):
			scroll_settings(i[1])
			break
	
func scroll_settings(i: int) -> void:
	position.y = clamp(position.y + (i * SCROLL_SPEED), -max_bottom - 20, 0)
