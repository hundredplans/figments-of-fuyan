extends Control

@onready var StatBox: HBoxContainer = %StatBox
var Unit: UnitGD

func onUpdateStat(stat_changed: String) -> void:
	var stat_change: int = 0
	if stat_changed == "Attack":
		stat_change = Unit.attack - Unit.base_card.attack
	else:
		stat_change = Unit.get("max_" + stat_changed.to_lower()) - Unit.base_card[stat_changed.to_lower()]
	var label: Label = StatBox.get_node(stat_changed + "/Label")
	label.text = ("+" if stat_change >= 0 else "") + str(stat_change)
	if label.text.length() > 2: label.label_settings = preload("res://assets/UI/sixty_four/sixty_four_small.tres")
	else: label.label_settings = preload("res://assets/UI/sixty_four/sixty_four_medium.tres")
