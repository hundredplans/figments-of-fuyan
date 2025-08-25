extends BoonGD

const TIER_ONE_CHARGES: int = 4
const TIER_TWO_CHARGES: int = 3
const TIER_THREE_CHARGES: int = 2
const TIER_FOUR_CHARGES: int = 1

const ENERGY_GAIN: int = 1

func onProcessAction(action: Action) -> void:
	super(action)
	if action.post:
		if action is DeathAction and action.Defender.isAlly(0):
			onPushAction(ChangeBoonChargesAction.new(self, 1))

func getDescription(use_default_values: bool = false) -> String:
	return super(use_default_values)

func onChangeCharges(delta: int) -> void:
	super(delta)
	if charges >= getTierCharges():
		onPushAction(BoonActivatedAction.new(self, null))

func onBoon(_action: Action = null) -> void:
	var actions: Array = [ChangeBoonChargesAction.new(self, -charges),\
	EnergyAction.new(ENERGY_GAIN)]
	onPushAction(actions)

func onRetiered(_tier: int) -> void:
	super(_tier)
	if charges >= getTierCharges():
		onPushAction(BoonActivatedAction.new(self, null))

func onBoonAdded() -> void:
	super()

func getDisabled() -> bool:
	return super()

func getCharges() -> int:
	return super()
	
func onCardTurnPassed(Card: CardGD) -> void:
	super(Card)

func getTierCharges() -> int:
	match tier:
		1: return TIER_ONE_CHARGES
		2: return TIER_TWO_CHARGES
		3: return TIER_THREE_CHARGES
		4: return TIER_FOUR_CHARGES
	return 0
