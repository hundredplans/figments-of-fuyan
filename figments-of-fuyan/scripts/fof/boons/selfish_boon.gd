extends BoonGD

const TIER_ONE_MAX_HP: int = 0
const TIER_TWO_MAX_HP: int = 1
const TIER_THREE_MAX_HP: int = 2
const TIER_FOUR_MAX_HP: int = 3

const DELAY: float = 2.0

func onProcessAction(action: Action) -> void:
	super(action)
	if action is AwakenAction and action.Card.isAlly(0) and action.Card.getRarity() == Game.Rarities.CHAMPION:
		onPushAction(BoonActivatedAction.new(self, action))
	
func onRetiered(_tier: int) -> void:
	var old_tier: int = tier
	super(_tier)
	if old_tier == tier: return
	
	var value: int = getTierMaxHp(tier) - getTierMaxHp(old_tier)
	onPushAction(getStatAction(Game.getSaveFile().getChampionCard(), value))
	
func getDescription(use_default_values: bool = false) -> String:
	return super(use_default_values)

func onBoon(action: Action) -> void:
	if action is DamageAction:
		var allies: Array = Game.getSaveFile().getChampionCard().getVisibleFieldCardsAllies()
		if allies.is_empty(): return
		var RandomAlly: CardGD = allies.pick_random()
		
		#var spectate_object: GameObjectGD = Game.getLevel().getSpectateObject()
		var damage_action := DamageAction.new(self, RandomAlly, 1, Game.DamageTypes.OTHER)
		#damage_action.setActionDelay(DELAY)
		#var actions: Array = [CameraChangeAction.new(RandomAlly), damage_action, CameraChangeAction.new(spectate_object)]
		var actions: Array = [damage_action]
		onPushAction(actions)
	elif action is AwakenAction:
		onPushAction(getStatAction(action.Card, getTierMaxHp()))

func getStatAction(Card: CardGD, value: int) -> StatAction:
	if Card == null: return
	return StatAction.new(StatInfo.new(Card, [Game.Stats.MAX_HEALTH, Game.Stats.HEALTH], [value, value]))

func onBoonAdded() -> void:
	super()
	onPushAction(getStatAction(Game.getSaveFile().getChampionCard(), getTierMaxHp()))

func getDisabled() -> bool:
	return super()

func getCharges() -> int:
	return super()
	
func onCardTurnPassed(Card: CardGD) -> void:
	super(Card)

func getTierMaxHp(_tier: int = tier) -> int:
	match _tier:
		1: return TIER_ONE_MAX_HP
		2: return TIER_TWO_MAX_HP
		3: return TIER_THREE_MAX_HP
		4: return TIER_FOUR_MAX_HP
	return 0
