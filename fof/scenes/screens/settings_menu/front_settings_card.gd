extends Control
var setting: String

func on_load_setting_card(_setting: String) -> void:
	$Background/Inside.color = Color(Helper.settings_color_dict[_setting])
	$CardName.text = _setting
	name = _setting
	setting = _setting

	$LoadedSetting.add_child(load("res://scenes/screens/settings_menu/setting_options/settings_" + _setting.to_lower() + ".tscn").instantiate())
	$SettingsEnter.play("settings_enter")
