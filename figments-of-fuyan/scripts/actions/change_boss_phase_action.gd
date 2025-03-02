class_name ChangeBossPhaseAction extends Action

func _init() -> void:
	super()
	
func onPreAction() -> void:
	setActionDelay(Game.getLevel().getBoss().getChangeDelayFromInfo())
	
func onPostAction() -> void:
	var BossCard: BossCardGD = Game.getLevel().getBoss()
	BossCard.onChangeBossPhase()
