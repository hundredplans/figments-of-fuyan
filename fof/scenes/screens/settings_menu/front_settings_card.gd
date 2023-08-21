extends Control
var setting: String

func on_load_setting_card(_setting: String) -> void:
	$Background/Inside.color = Color(Helper.settings_color_dict[_setting])
	$CardName.text = _setting
	name = _setting
	setting = _setting
