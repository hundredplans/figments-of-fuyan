extends BoonGD

const MAX_CHARGES: int = 4

func onProcessAction(action: Action) -> void:
	super(action)
	if action.post:
		if action is DeathAction and action.Defender.isAlly(0) and charges < MAX_CHARGES:
			onPushAction(ChangeBoonChargesAction.new(self, 1))
		elif action is AwakenAction and action.owner is PlayCardAction and charges == MAX_CHARGES:
			onPushAction(BoonActivatedAction.new(self, action))
			
func onBoon(action: AwakenAction) -> void:
	var actions: Array = [ChangeBoonChargesAction.new(self, -MAX_CHARGES),
		StatAction.new(StatInfo.new(action.Card, Game.Stats.MAX_SPEED, 1 if tier == 1 else 2))]
	onPushAction(actions)

func onBoonAdded() -> void:
	super()

func getDisabled() -> bool:
	return super()

func getCharges() -> int:
	return super()
	
func onCardTurnPassed(Card: CardGD) -> void:
	super(Card)
