extends BoonGD

const TIER_ONE_AMOUNT: int = 1
const TIER_TWO_AMOUNT: int = 2
const TIER_THREE_AMOUNT: int = 3
const TIER_FOUR_AMOUNT: int = 4

const SHIELD_ID: int = 3
const BOUNCY_SHIELD_ID: int = 20

func onProcessAction(action: Action) -> void:
	super(action)
	if action.post:
		if action is ChangePhaseAction and action.phase == Game.Phases.START:
			onPushAction(BoonActivatedAction.new(self, action))
	
func getDescription(use_default_values: bool = false) -> String:
	return super(use_default_values)

func onBoon(action: ChangePhaseAction) -> void:
	var enemy_cards: Array = Game.getAllyUnits(1)
	enemy_cards = enemy_cards.filter(func(x: CardGD): return x.getHealth() > 1)
	enemy_cards.shuffle()
	enemy_cards.resize(getTierAmount())
	enemy_cards = enemy_cards.filter(func(x: CardGD): return x != null)
	for EnemyCard: CardGD in enemy_cards:
		EnemyCard.onCreateBaseFieldEffect(BOUNCY_SHIELD_ID)

func onBoonAdded() -> void:
	super()

func getDisabled() -> bool:
	return super()

func getCharges() -> int:
	return super()
	
func onCardTurnPassed(Card: CardGD) -> void:
	super(Card)

func getTierAmount() -> int:
	match tier:
		1: return TIER_ONE_AMOUNT
		2: return TIER_TWO_AMOUNT
		3: return TIER_THREE_AMOUNT
		4: return TIER_FOUR_AMOUNT
	return 0
