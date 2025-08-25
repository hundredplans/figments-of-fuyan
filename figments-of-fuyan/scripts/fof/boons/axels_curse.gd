extends BoonGD

const TIER_ONE_TURNS: int = 2
const TIER_TWO_TURNS: int = 2
const TIER_THREE_TURNS: int = 3
const TIER_FOUR_TURNS: int = 4

const FATAL_ID: int = 7

func onProcessAction(action: Action) -> void:
	super(action)
	if action.post:
		if action is DamageAction and action.owner is AttackAction and action.Damager.isAlly(1) and action.Defenders.any(func(x: GameObjectGD): return x is CardGD):
			onPushAction(BoonActivatedAction.new(self, action))

func getDescription(use_default_values: bool = false) -> String:
	return super(use_default_values)

func onBoon(action: DamageAction) -> void:
	var Attacker: CardGD = action.Damager
	Attacker.onCreateBaseStatusEffect(FATAL_ID, getTurns())

func onBoonAdded() -> void:
	super()

func getDisabled() -> bool:
	return super()

func getCharges() -> int:
	return super()
	
func onCardTurnPassed(Card: CardGD) -> void:
	super(Card)

func getTurns() -> int:
	match tier:
		1: return TIER_ONE_TURNS
		2: return TIER_TWO_TURNS
		3: return TIER_THREE_TURNS
		4: return TIER_FOUR_TURNS
	return 0
