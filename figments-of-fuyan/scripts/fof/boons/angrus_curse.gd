extends BoonGD

var cards_triggered_public_ids: Array
const TIER_ONE_ATTACK: int = 1
const TIER_TWO_ATTACK: int = 2
const TIER_THREE_ATTACK: int = 3
const TIER_FOUR_ATTACK: int = 4

func onProcessAction(action: Action) -> void:
	super(action)
	if action.post:
		if action is DeathAction and action.Damager is CardGD and action.Damager.isAlly(1) and action.Damager.isAlive()\
			and action.Damager.public_id not in cards_triggered_public_ids:
			onPushAction(BoonActivatedAction.new(self, action))
		elif action is AwakenAction and action.Card.isAlly(1):
			onPushAction(BoonActivatedAction.new(self, action))

func getDescription(use_default_values: bool = false) -> String:
	return super(use_default_values)

func onBoon(action: Action) -> void:
	if action is DeathAction:
		cards_triggered_public_ids.append(action.Damager.public_id)
		onPushAction(StatAction.new(StatInfo.new(action.Damager, Game.Stats.ATTACK, -getTierAttack())))
	elif action is AwakenAction:
		onPushAction(StatAction.new(StatInfo.new(action.Card, Game.Stats.ATTACK, getTierAttack())))

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

func getTierAttack() -> int:
	match tier:
		1: return TIER_ONE_ATTACK
		2: return TIER_TWO_ATTACK
		3: return TIER_THREE_ATTACK
		4: return TIER_FOUR_ATTACK
	return 0
