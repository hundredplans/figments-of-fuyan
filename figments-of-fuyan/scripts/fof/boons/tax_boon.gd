extends BoonGD

const TIER_ONE_MIN_SH: int = 2
const TIER_TWO_MIN_SH: int = 4
const TIER_THREE_MIN_SH: int = 6
const TIER_FOUR_MIN_SH: int = 10

const TIER_ONE_MAX_SH: int = 4
const TIER_TWO_MAX_SH: int = 6
const TIER_THREE_MAX_SH: int = 8
const TIER_FOUR_MAX_SH: int = 12

func onProcessAction(action: Action) -> void:
	super(action)
	if action.post:
		if action is EndGameAction and action.team == 1:
			onPushAction(BoonActivatedAction.new(self, action))

func getDescription(use_default_values: bool = false) -> String:
	return super(use_default_values)

func onBoon(_action: Action = null) -> void:
	var sh: int = randi_range(getTierMinSh(), getTierMaxSh())
	onPushAction(ChangeShillingsAction.new(sh))

func onBoonAdded() -> void:
	super()

func getDisabled() -> bool:
	return super()

func getCharges() -> int:
	return super()
	
func onCardTurnPassed(Card: CardGD) -> void:
	super(Card)

func getTierMinSh() -> int:
	match tier:
		1: return TIER_ONE_MIN_SH
		2: return TIER_TWO_MIN_SH
		3: return TIER_THREE_MIN_SH
		4: return TIER_FOUR_MIN_SH
	return 0
	
func getTierMaxSh() -> int:
	match tier:
		1: return TIER_ONE_MAX_SH
		2: return TIER_TWO_MAX_SH
		3: return TIER_THREE_MAX_SH
		4: return TIER_FOUR_MAX_SH
	return 0
