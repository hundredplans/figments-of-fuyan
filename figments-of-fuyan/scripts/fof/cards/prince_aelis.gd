extends CardGD

const TIER_ONE_ENERGY: int = 1
const TIER_TWO_ENERGY: int = 1
const TIER_THREE_ENERGY: int = 2
const TIER_FOUR_ENERGY: int = 3

func onChangeHandCardsEnergy(delta: int) -> void:
	for HandCard: CardGD in get_tree().get_nodes_in_group("HandCardsGD"):
		onPushAction(CardEnergyAction.new(HandCard, delta))

func onProcessAction(action: Action) -> void:
	super(action)
	if isValidArrive(action):
		onChangeHandCardsEnergy(-getTierEnergy())
	elif isValidLastWill(action):
		onChangeHandCardsEnergy(getTierEnergy())
	elif action.post and action is HandCardAction and isAlive():
		onPushAction(CardEnergyAction.new(action.Card, -getTierEnergy()))
	
func getTierEnergy() -> int:
	match tier:
		1: return TIER_ONE_ENERGY
		2: return TIER_TWO_ENERGY
		3: return TIER_THREE_ENERGY
		4: return TIER_FOUR_ENERGY
	return 0
