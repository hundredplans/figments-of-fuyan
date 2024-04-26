extends Control

var Unit: UnitGD
@onready var GameCard: GameCardGD = %GameCard
@onready var BuffManager: Control = %BuffManager

func setUnit(_Unit: UnitGD) -> void:
	Unit = _Unit
	GameCard.set_info(Unit.base_card)
	BuffManager.Unit = Unit
	
	for stat in ["Attack", "Health", "Speed"]:
		BuffManager.onUpdateStat(stat)
	
