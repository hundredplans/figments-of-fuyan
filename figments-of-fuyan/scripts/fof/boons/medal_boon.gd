extends BoonGD

const TIER_ONE_ATTACK: int = 1
const TIER_TWO_ATTACK: int = 1
const TIER_THREE_ATTACK: int = 2
const TIER_FOUR_ATTACK: int = 2

const TIER_ONE_MAX_HP: int = 1
const TIER_TWO_MAX_HP: int = 1
const TIER_THREE_MAX_HP: int = 1
const TIER_FOUR_MAX_HP: int = 2

const TIER_ONE_SPEED: int = 0
const TIER_TWO_SPEED: int = 1
const TIER_THREE_SPEED: int = 1
const TIER_FOUR_SPEED: int = 1

var active_card_public_id: int

func onProcessAction(action: Action) -> void:
	super(action)
	if action.post:
		if action is AwakenAction and isTwoOrLessAllyAlive() and action.Card.isAlly(0):
			onPushAction(BoonActivatedAction.new(self, action))
		elif action is DeathAction and isTwoOrLessAllyAlive() and !isNoAllyAlive() and action.Defender.isAlly(0):
			onPushAction(BoonActivatedAction.new(self, action))

func onSave() -> SavedDataBoon:
	ability_save["active_card_public_id"] = active_card_public_id
	return super()

func getDescription(use_default_values: bool = false) -> String:
	return super(use_default_values)

func onBoon(_action: Action) -> void:
	var values: Array = [getTierAttack(), getTierMaxHp(), getTierMaxHp(), getTierSpeed()]
	var types: Array = [Game.Stats.ATTACK, Game.Stats.MAX_HEALTH, Game.Stats.HEALTH, Game.Stats.MAX_SPEED]
	var ActiveCard: CardGD
	if isOneAllyAlive():
		ActiveCard = getLastAllyAlive()
		active_card_public_id = ActiveCard.public_id
	else:
		ActiveCard = Game.onFindPublicIDObject(active_card_public_id)
		values = values.map(func(x: int): return x * -1)
	if ActiveCard == null: return
	onPushAction(StatAction.new(StatInfo.new(ActiveCard, types, values)))

func onBoonAdded() -> void:
	super()
	if isOneAllyAlive():
		onPushAction(BoonActivatedAction.new(self, null))

func onRemoveBoon() -> void:
	if isOneAllyAlive():
		onForceAction(BoonActivatedAction.new(self, null))

func onRetiered(_tier: int) -> void:
	var old_tier: int = tier
	super(_tier)
	if old_tier == tier: return
	if !isOneAllyAlive(): return
	
	var ActiveCard: CardGD = Game.onFindPublicIDObject(active_card_public_id)
	if ActiveCard == null: return
	var new_attack: int = getTierAttack(tier)
	var new_health: int = getTierMaxHp(tier)
	var new_speed: int = getTierSpeed(tier)
	
	var old_attack: int = getTierAttack(old_tier)
	var old_health: int = getTierMaxHp(old_tier)
	var old_speed: int = getTierSpeed(old_tier)
	
	var attack: int = new_attack - old_attack
	var health: int = new_health - old_health
	var speed: int = new_speed - old_speed
	onPushAction(StatAction.new(StatInfo.new(ActiveCard,\
	[Game.Stats.ATTACK, Game.Stats.MAX_HEALTH, Game.Stats.HEALTH, Game.Stats.MAX_SPEED],\
	[attack, health, health, speed])))

func getDisabled() -> bool:
	return super()

func getCharges() -> int:
	return super()
	
func onCardTurnPassed(Card: CardGD) -> void:
	super(Card)

func getTierAttack(_tier: int = tier) -> int:
	match _tier:
		1: return TIER_ONE_ATTACK
		2: return TIER_TWO_ATTACK
		3: return TIER_THREE_ATTACK
		4: return TIER_FOUR_ATTACK
	return 0
	
func getTierMaxHp(_tier: int = tier) -> int:
	match _tier:
		1: return TIER_ONE_MAX_HP
		2: return TIER_TWO_MAX_HP
		3: return TIER_THREE_MAX_HP
		4: return TIER_FOUR_MAX_HP
	return 0

func getTierSpeed(_tier: int = tier) -> int:
	match _tier:
		1: return TIER_ONE_SPEED
		2: return TIER_TWO_SPEED
		3: return TIER_THREE_SPEED
		4: return TIER_FOUR_SPEED
	return 0
	
func isNoAllyAlive() -> bool:
	return Game.getAllyUnits(0).is_empty()
	
func isOneAllyAlive() -> bool:
	return Game.getAllyUnits(0).size() == 1
	
func isTwoOrLessAllyAlive() -> bool:
	return Game.getAllyUnits(0).size() <= 2
	
func getLastAllyAlive() -> CardGD:
	return Game.getAllyUnits(0)[0]
