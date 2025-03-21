extends BoonGD

var max_kills: int = 1
func onProcessAction(action: Action) -> void:
	super(action)
	if action.post:
		if action is DeathAction and action.Damager is CardGD and action.Damager.isAlly(0) and action.Damager.isValidRampage(action)\
		and charges > 0 and action.Damager.info.id != 1:
			onPushAction(BoonActivatedAction.new(self, action))
	
func onAscend(state: bool) -> void:
	super(state)

func getDescription() -> String:
	return Helper.getDescription(super(), [charges])

func onBoon(action: Action = null) -> void:
	onPushAction(ChangeBoonChargesAction.new(self, -1))
	onPushAction(StatAction.new(StatInfo.new(action.Damager, Game.Stats.MAX_HEALTH, 1)))

func onBoonAdded() -> void:
	super()
	
func getDisabled() -> bool:
	return charges == 0
	
func onResetCharges() -> void:
	super()
	
func getDefaultCharges() -> int:
	return max_kills
	
func onSave() -> SavedDataBoon:
	ability_save['max_kills'] = max_kills
	return super()
