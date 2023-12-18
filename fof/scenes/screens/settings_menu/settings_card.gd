extends Control
var setting: String

func on_load_setting_card(_setting: String) -> void:
	setting = _setting
	$Settings/CardName.text = setting
	name = setting

func on_load_front_card() -> void:
	var settings_option: Control = load("res://scenes/screens/settings_menu/setting_options/settings_" + setting.to_lower() + ".tscn").instantiate()
	settings_option.setting = setting
	$Settings/LoadedSetting.add_child(settings_option)
	$Settings/UtilityMenu/PageZone.visible = settings_option.get_child_count() != 1
	
	page = 0
	on_reload_page(0)

func on_load_back_card() -> void:
	for child in $Settings/LoadedSetting.get_children():
		child.queue_free()

var page: int = 0
func on_reload_page(i: int) -> void:
	if has_node("Settings/LoadedSetting/Settings" + setting.capitalize()):
		var setting_parent: Control = $Settings/LoadedSetting.get_node("Settings" + setting.capitalize())
		var max_page: int = setting_parent.get_child_count() - 1
		page = clamp(page + i, 0, max_page)
		for page_node in setting_parent.get_children():
			page_node.visible = int(str(page_node.name)) == page
			
		$Settings/UtilityMenu/PageZone/LeftArrow.disabled = page == 0
		$Settings/UtilityMenu/PageZone/RightArrow.disabled = page == max_page
		$Settings/UtilityMenu/PageZone/Page.text = str(page)
