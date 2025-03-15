extends BoonGD

const MAX_CHARGES: int = 4
const UNASCENDED_SPEED_GAIN: int = 1
const ASCENDED_SPEED_GAIN: int = 2

func onProcessAction(action: Action) -> void:
	super(action)
	if action.post:
		if action is DeathAction and action.Defender.isAlly(0) and charges < MAX_CHARGES:
			onPushAction(ChangeBoonChargesAction.new(self, 1))
		elif action is AwakenAction and action.owner is PlayCardAction and charges == MAX_CHARGES:
			onPushAction(BoonActivatedAction.new(self, action))
	
func onAscend(state: bool) -> void:
	super(state)

func getDescription() -> String:
	return super()

func onBoon(action: AwakenAction) -> void:
	var actions: Array = [ChangeBoonChargesAction.new(self, -MAX_CHARGES),
		StatAction.new(StatInfo.new(action.Card, Game.Stats.MAX_SPEED, UNASCENDED_SPEED_GAIN if !ascended else ASCENDED_SPEED_GAIN))]
	onPushAction(actions)
	

func onBoonAdded() -> void:
	super()

func getDisabled() -> bool:
	return super()

func getCharges() -> int:
	return super()
	
func onCardTurnPassed(Card: CardGD) -> void:
	super(Card)
