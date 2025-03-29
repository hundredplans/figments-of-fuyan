class_name ChangeBossPhaseAction extends Action

func _init() -> void:
	super()
	
func onPreAction() -> void:
	var BossCard: EpicCardGD = Game.getLevel().getBoss()
	var delay: float = BossCard.getChangeDelayFromInfo()
	setActionDelay(delay)
	
func onPostAction() -> void:
	var BossCard: EpicCardGD = Game.getLevel().getBoss()
	BossCard.onChangeBossPhase()
	
	var hurt_action: HurtAction = Game.ActionManagerReference.onFindFirstAction(HurtAction)
	if hurt_action != null and hurt_action.Defender == BossCard: hurt_action.onFailAction()
