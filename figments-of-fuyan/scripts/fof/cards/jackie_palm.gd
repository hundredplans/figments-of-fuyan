extends CardGD

func onProcessAction(action: Action) -> void:
	super(action)
	if isValidRevenge(action):
		onPushAction(RevengeAction.new(self, action.owner, true))
	
func getDescription() -> String:
	return super()
	
func onRevenge(action: DamageAction) -> void:
	super(action)
	var palm_ids: Array = Helper.getFofInfoID(AreaInfo, 1).card_ids
	if getVisibleFieldCardsAllies().any(func(x: CardGD): return x.info.id in palm_ids):
		onPushAction(StatAction.new(StatInfo.new(self, Game.Stats.HEALTH, 1)))
