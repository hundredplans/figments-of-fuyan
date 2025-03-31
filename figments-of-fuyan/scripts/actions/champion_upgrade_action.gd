class_name ChampionUpgradeAction extends Action

const CHAMPION_UPGRADE_UI_PATH: String = "res://scenes/common/champion_upgrade_ui/champion_upgrade_ui.tscn"
const RUN_FINISH_UI_PATH: String = "res://scenes/game/levels/ui/run_finish_ui.tscn"

func _init() -> void:
	super()
	
func onPreAction() -> void:
	pass
	
func onPostAction() -> void:
	Game.getSaveFile().onUpgradeChampion()
	
	var ChampionUpgradeUI: Control = load(CHAMPION_UPGRADE_UI_PATH if Game.getSaveFile().upgrade_level == 1 else RUN_FINISH_UI_PATH).instantiate()
	Game.getSaveFile().get_parent().get_parent().add_child(ChampionUpgradeUI)
	ChampionUpgradeUI.setInfo()
