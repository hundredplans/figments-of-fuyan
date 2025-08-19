extends BoonGD

const TIER_ONE_ENERGY_GAIN: int = 1
const TIER_TWO_ENERGY_GAIN: int = 2
const TIER_THREE_ENERGY_GAIN: int = 2
const TIER_FOUR_ENERGY_GAIN: int = 4

const TIER_ONE_CARD_REQUIREMENT: int = 2
const TIER_TWO_CARD_REQUIREMENT: int = 2
const TIER_THREE_CARD_REQUIREMENT: int = 2
const TIER_FOUR_CARD_REQUIREMENT: int = 3

const TIER_ONE_DRAW_AMOUNT: int = 0
const TIER_TWO_DRAW_AMOUNT: int = 0
const TIER_THREE_DRAW_AMOUNT: int = 1
const TIER_FOUR_DRAW_AMOUNT: int = 2

func onProcessAction(action: Action) -> void:
	super(action)
	if action.post:
		if action is ChangePhaseAction and action.phase == Game.Phases.HAND:
			onResetCharges()
		elif action is PlayCardAction:
			onPushAction(ChangeBoonChargesAction.new(self, 1))

func onBoon(_action: Action = null) -> void:
	var energy_gain: int = getEnergyGain()
	onPushAction(EnergyAction.new(energy_gain))
	
	for __: int in range(getDrawAmount()):
		onPushAction(DrawAction.new())
	
func onChangeCharges(delta: int) -> void:
	super(delta)
	if charges != 0 and charges % getCardRequirement() == 0:
		onPushAction(BoonActivatedAction.new(self, null))
	
func getDrawAmount() -> int:
	match tier:
		1: return TIER_ONE_DRAW_AMOUNT
		2: return TIER_TWO_DRAW_AMOUNT
		3: return TIER_THREE_DRAW_AMOUNT
		4: return TIER_FOUR_DRAW_AMOUNT
	return 0
	
func getEnergyGain() -> int:
	match tier:
		1: return TIER_ONE_ENERGY_GAIN
		2: return TIER_TWO_ENERGY_GAIN
		3: return TIER_THREE_ENERGY_GAIN
		4: return TIER_FOUR_ENERGY_GAIN
	return 0
	
func getCardRequirement() -> int:
	match tier:
		1: return TIER_ONE_CARD_REQUIREMENT
		2: return TIER_TWO_CARD_REQUIREMENT
		3: return TIER_THREE_CARD_REQUIREMENT
		4: return TIER_FOUR_CARD_REQUIREMENT
	return 0
