extends BoonGD

func onProcessAction(action: Action) -> void:
	super(action)
	if action.post:
		if action is AwakenAction and action.Card.info.id == 7 and action.Card.isEnemy(0):
			onPushAction(BoonActivatedAction.new(self, action))
	
func onAscend(state: bool) -> void:
	super(state)

func getDescription() -> String:
	return super()

func onBoon(action: Action = null) -> void:
	onPushAction(StatAction.new(StatInfo.new(action.Card, Game.Stats.ATTACK, 1)))

func onBoonAdded() -> void:
	pass

func getDisabled() -> bool:
	return super()

func getCharges() -> int:
	return super()
