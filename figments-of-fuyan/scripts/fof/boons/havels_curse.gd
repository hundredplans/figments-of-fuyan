extends BoonGD

const TIER_ONE_ATTACK: int = 1
const TIER_TWO_ATTACK: int = 1
const TIER_THREE_ATTACK: int = 2
const TIER_FOUR_ATTACK: int = 2

const TIER_ONE_MAX_HP: int = 0
const TIER_TWO_MAX_HP: int = 1
const TIER_THREE_MAX_HP: int = 1
const TIER_FOUR_MAX_HP: int = 2

func onProcessAction(action: Action) -> void:
	super(action)
	if action.post and action is StatAction and action.owner is DamageAction and action.owner.damage > 0 and\
	action.owner.damage_type != Game.DamageTypes.FALL_DAMAGE and action.getCards().any(func(x: CardGD): return x.isAlly(1)):
		onPushAction(BoonActivatedAction.new(self, action))

func getDescription(use_default_values: bool = false) -> String:
	return super(use_default_values)

func onBoon(action: StatAction) -> void:
	var enemy_cards: Array = action.getCards().filter(func(x: CardGD): return x.isAlly(1))
	onPushAction(StatAction.new(enemy_cards.map(func(x: CardGD):\
		return StatInfo.new(x, [Game.Stats.ATTACK, Game.Stats.MAX_HEALTH, Game.Stats.HEALTH], [getTierAttack(), getTierMaxHp(), getTierMaxHp()]))))

func onBoonAdded() -> void:
	super()

func getDisabled() -> bool:
	return super()

func getCharges() -> int:
	return super()
	
func onCardTurnPassed(Card: CardGD) -> void:
	super(Card)

func getTierAttack() -> int:
	match tier:
		1: return TIER_ONE_ATTACK
		2: return TIER_TWO_ATTACK
		3: return TIER_THREE_ATTACK
		4: return TIER_FOUR_ATTACK
	return 0
	
func getTierMaxHp() -> int:
	match tier:
		1: return TIER_ONE_MAX_HP
		2: return TIER_TWO_MAX_HP
		3: return TIER_THREE_MAX_HP
		4: return TIER_FOUR_MAX_HP
	return 0
