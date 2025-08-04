extends CardGD

const TIER_ONE_TURNS: int = 1
const TIER_TWO_TURNS: int = 1
const TIER_THREE_TURNS: int = 2
const TIER_FOUR_TURNS: int = 2
const REVENGE_DELAY: float = 2.0

func onProcessAction(action: Action) -> void:
	super(action)
	if isValidRevenge(action):
		onPushAction(RevengeAction.new(self, action.owner))

func onRevenge(_action: DamageAction) -> void:
	var allies: Array = getVisibleFieldCardsAllies()
	if allies.is_empty(): return
	allies.shuffle()
	
	allies.sort_custom(func(x: CardGD, y: CardGD):\
		return Game.getCoordsDistance(x.getCoords(), getCoords()) < Game.getCoordsDistance(y.getCoords(), getCoords()))
	
	var animation_action := AnimationAction.new(self, "Ability")
	animation_action.setActionDelay(REVENGE_DELAY)
	onPushAction([animation_action, StatAction.new(StatInfo.new(allies[0], Game.Stats.ATTACK, 1, getTierTurns()))])
	
func getTierTurns() -> int:
	match tier:
		1: return TIER_ONE_TURNS
		2: return TIER_TWO_TURNS
		3: return TIER_THREE_TURNS
		4: return TIER_FOUR_TURNS
	return 0
