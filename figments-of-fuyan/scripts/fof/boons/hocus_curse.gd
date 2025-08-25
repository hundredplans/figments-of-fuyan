extends BoonGD

var cards_triggered_public_ids: Array
const TIER_ONE_HEAL: int = 2
const TIER_TWO_HEAL: int = 3
const TIER_THREE_HEAL: int = 4
const TIER_FOUR_HEAL: int = 5

func onProcessAction(action: Action) -> void:
	super(action)
	if action.post and action is StatAction and action.owner is DamageAction and action.owner.damage > 0 and\
	action.owner.damage_type != Game.DamageTypes.FALL_DAMAGE and action.owner.Defenders.any(func(x: CardGD): return x.isAlly(1))\
	and !(action.owner.Defenders.all(func(x: CardGD): return x.public_id in cards_triggered_public_ids or x.getHealth() == 0)):
		onPushAction(BoonActivatedAction.new(self, action))

func getDescription(use_default_values: bool = false) -> String:
	return super(use_default_values)

func onBoon(action: StatAction) -> void:
	var defenders: Array = action.owner.Defenders
	defenders = defenders.filter(func(x: CardGD): return x.isAlly(1) and x.public_id not in cards_triggered_public_ids and x.getHealth() > 0)
	cards_triggered_public_ids += defenders.map(func(x: CardGD): return x.public_id)
	onPushAction(HealAction.new(defenders.map(func(x: CardGD): return HealDatastore.new(x, getTierHeal()))))

func onBoonAdded() -> void:
	super()

func getDisabled() -> bool:
	return super()

func getCharges() -> int:
	return super()
	
func onCardTurnPassed(Card: CardGD) -> void:
	super(Card)

func onSave() -> SavedDataBoon:
	ability_save['cards_triggered_public_ids'] = cards_triggered_public_ids
	return super()

func getTierHeal() -> int:
	match tier:
		1: return TIER_ONE_HEAL
		2: return TIER_TWO_HEAL
		3: return TIER_THREE_HEAL
		4: return TIER_FOUR_HEAL
	return 0
