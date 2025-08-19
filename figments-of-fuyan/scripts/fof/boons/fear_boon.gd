extends BoonGD

const DAZE_ID: int = 5

const MINIMUM_TIER_TO_STUN: int = 2
const TIER_ONE_TURNS: int = 2
const TIER_TWO_TURNS: int = 2
const TIER_THREE_TURNS: int = 3
const TIER_FOUR_TURNS: int = 4

func onAdvanceTurn(team: int) -> void:
	super(team)
	if team == 1 and charges > 0:
		onPushAction(ChangeBoonChargesAction.new(self, -1))
	
func onBoon(__: Action) -> void:
	var turns: int = getTurns()
	for EnemyCard: CardGD in Game.getEnemyUnits(0):
		if tier >= MINIMUM_TIER_TO_STUN:
			EnemyCard.onStun(turns)
		else:
			pass
			EnemyCard.onCreateBaseStatusEffectAction(DAZE_ID, turns, self)

func onBoonAdded() -> void:
	super()
	
func onLevelStarted() -> void:
	super()
	onPushAction(BoonActivatedAction.new(self, null))
	
func getDefaultCharges() -> int:
	return getTurns()

func getDisabled() -> bool:
	return super() or charges == 0
	
func getTurns() -> int:
	match tier:
		1: return TIER_ONE_TURNS
		2: return TIER_TWO_TURNS
		3: return TIER_THREE_TURNS
		4: return TIER_FOUR_TURNS
	return 0
