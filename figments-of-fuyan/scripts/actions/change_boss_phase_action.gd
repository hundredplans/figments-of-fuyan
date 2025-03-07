class_name ChangeBossPhaseAction extends Action

func _init() -> void:
	super()
	
func onPreAction() -> void:
	setActionDelay(Game.getLevel().getBoss().getChangeDelayFromInfo())
	
func onPostAction() -> void:
	var BossCard: BossCardGD = Game.getLevel().getBoss()
	BossCard.onChangeBossPhase()
	
	var hurt_action: HurtAction = Game.ActionManagerReference.onFindFirstAction(HurtAction)
	if hurt_action != null and hurt_action.Defender == BossCard: hurt_action.onFailAction()
