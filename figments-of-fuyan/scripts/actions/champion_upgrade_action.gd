class_name ChampionUpgradeAction extends Action

const CHAMPION_UPGRADE_UI_PATH: String = "res://scenes/common/champion_upgrade_ui/champion_upgrade_ui.tscn"

var old_deck_limit: int
var old_energy_limit: int
var old_max_energy: int

func _init(_old_deck_limit: int = 0, _old_energy_limit: int = 0, _old_max_energy: int = 0) -> void:
	super()
	old_deck_limit = _old_deck_limit
	old_energy_limit = _old_energy_limit
	old_max_energy = _old_max_energy

func onPreAction() -> void:
	pass
	
func onPostAction() -> void:
	var ChampionCard: CardGD = Game.getSaveFile().getChampionCard()
	ChampionCard.onTierUp()
