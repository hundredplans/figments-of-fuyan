extends BoonGD

const TIER_ONE_DEFAULT_HAND_SIZE: int = 1
const TIER_TWO_DEFAULT_HAND_SIZE: int = 2
const TIER_THREE_DEFAULT_HAND_SIZE: int = 2
const TIER_FOUR_DEFAULT_HAND_SIZE: int = 2

const TIER_ONE_END_OF_TURN_CARD_DRAW: int = 0
const TIER_TWO_END_OF_TURN_CARD_DRAW: int = 0
const TIER_THREE_END_OF_TURN_CARD_DRAW: int = 1
const TIER_FOUR_END_OF_TURN_CARD_DRAW: int = 4

func onProcessAction(action: Action) -> void:
	super(action)

func getDescription(use_default_values: bool = false) -> String:
	return super(use_default_values)

func onBoon(_action: Action = null) -> void:
	pass

func onBoonAdded() -> void:
	super()
	var actions: Array = [ChangeDefaultHandSizeAction.new(getTierDefaultHandSize()),
		ChangeEndOfTurnCardDrawAction.new(getTierEndOfTurnCardDraw())]
	onPushAction(actions)
	
func onRetiered(_tier: int) -> void:
	var old_tier: int = tier
	super(_tier)
	if old_tier == tier: return
	var actions: Array = []
	var new_max_hand_size: int = getTierDefaultHandSize(tier)
	var old_default_hand_size: int = getTierDefaultHandSize(old_tier)
	var value: int = new_max_hand_size - old_default_hand_size
	actions.append(ChangeDefaultHandSizeAction.new(value))
	
	var new_eot_card_draw: int = getTierEndOfTurnCardDraw(tier)
	var old_eot_card_draw: int = getTierEndOfTurnCardDraw(old_tier)
	var eot: int = new_eot_card_draw - old_eot_card_draw
	actions.append(ChangeEndOfTurnCardDrawAction.new(eot))
	onPushAction(actions)

func getDisabled() -> bool:
	return super()

func getCharges() -> int:
	return super()
	
func onCardTurnPassed(Card: CardGD) -> void:
	super(Card)

func getTierDefaultHandSize(_tier: int = tier) -> int:
	match _tier:
		1: return TIER_ONE_DEFAULT_HAND_SIZE
		2: return TIER_TWO_DEFAULT_HAND_SIZE
		3: return TIER_THREE_DEFAULT_HAND_SIZE
		4: return TIER_FOUR_DEFAULT_HAND_SIZE
	return 0
	
func getTierEndOfTurnCardDraw(_tier: int = tier) -> int:
	match _tier:
		1: return TIER_ONE_END_OF_TURN_CARD_DRAW
		2: return TIER_TWO_END_OF_TURN_CARD_DRAW
		3: return TIER_THREE_END_OF_TURN_CARD_DRAW
		4: return TIER_FOUR_END_OF_TURN_CARD_DRAW
	return 0
	
