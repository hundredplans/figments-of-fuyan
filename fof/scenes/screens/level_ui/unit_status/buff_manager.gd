extends Control

@onready var StatBox: HBoxContainer = %StatBox
var Unit: UnitGD

func onUpdateStat(stat_changed: String) -> void:
	var stat_change: int = Unit.get("max_" + stat_changed.to_lower()) - Unit.base_card[stat_changed.to_lower()]
	StatBox.get_node(stat_changed + "/Label").text = ("+" if stat_change >= 0 else "") + str(stat_change)
