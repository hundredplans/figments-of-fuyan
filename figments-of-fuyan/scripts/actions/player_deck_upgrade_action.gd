class_name PlayerDeckUpgradeAction extends Action

var player_deck_upgrade: PlayerDeckUpgrade
func _init(_player_deck_upgrade: PlayerDeckUpgrade = null) -> void:
	super()
	player_deck_upgrade = _player_deck_upgrade
	
func onPreAction() -> void:
	pass
	
func onPostAction() -> void:
	Game.getSaveFile().onPlayerDeckUpgrade(player_deck_upgrade)
