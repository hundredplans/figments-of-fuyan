extends BoonGD

const TIER_ONE_DEATHS: int = 4
const TIER_TWO_DEATHS: int = 3
const TIER_THREE_DEATHS: int = 3
const TIER_FOUR_DEATHS: int = 2

const TIER_ONE_SPEED: int = 1
const TIER_TWO_SPEED: int = 1
const TIER_THREE_SPEED: int = 2
const TIER_FOUR_SPEED: int = 2

func onProcessAction(action: Action) -> void:
	super(action)
	if action.post:
		if action is DeathAction and action.Defender.isAlly(0) and charges < getDeaths():
			onPushAction(ChangeBoonChargesAction.new(self, 1))
		elif action is AwakenAction and action.owner is PlayCardAction and charges >= getDeaths():
			onPushAction(BoonActivatedAction.new(self, action))
			
func onBoon(action: AwakenAction) -> void:
	var actions: Array = [ChangeBoonChargesAction.new(self, -charges),
		StatAction.new(StatInfo.new(action.Card, Game.Stats.MAX_SPEED, getSpeed()))]
	onPushAction(actions)

func onBoonAdded() -> void:
	super()

func getDisabled() -> bool:
	return super()

func getCharges() -> int:
	return super()
	
func onCardTurnPassed(Card: CardGD) -> void:
	super(Card)
	
func getSpeed() -> int:
	match tier:
		1: return TIER_ONE_SPEED
		2: return TIER_TWO_SPEED
		3: return TIER_THREE_SPEED
		4: return TIER_FOUR_SPEED
	return 0
	
func getDeaths() -> int:
	match tier:
		1: return TIER_ONE_DEATHS
		2: return TIER_TWO_DEATHS
		3: return TIER_THREE_DEATHS
		4: return TIER_FOUR_DEATHS
	return 0
