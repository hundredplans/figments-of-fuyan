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

func on_load_back_card() -> void:
	for child in $Settings/LoadedSetting.get_children():
		child.queue_free()
