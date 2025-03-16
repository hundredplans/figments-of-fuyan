class_name ClearTileIntentsAction extends Action

func _init() -> void:
	super()
	
func onPreAction() -> void:
	pass
	
func onPostAction() -> void:
	var BossCard: EpicCardGD = Game.getLevel().getBoss()
	BossCard.boss_datastore.onClearTileIntents()
