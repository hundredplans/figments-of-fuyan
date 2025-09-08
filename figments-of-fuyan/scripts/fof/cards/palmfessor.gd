extends CardGD

var affected_cards: Array = []
const PALMFESSORS_STUDENT_ID: int = 6

const TIER_ONE_ATTACK_GAIN: int = 1
const TIER_TWO_ATTACK_GAIN: int = 2
const TIER_THREE_ATTACK_GAIN: int = 3
const TIER_FOUR_ATTACK_GAIN: int = 4


func onProcessAction(action: Action) -> void:
	super(action)
	if action.post:
		if card_place == Game.CardPlaces.FIELD:
			if action is VisionNewUnitAction and action.Discoverer == self and action.Discovered.isAlly(team):
				if action.enter_vision and action.Discovered.attack == 1:
					onAddToAura(action.Discovered)
				elif !action.enter_vision and action.Discovered in affected_cards:
					onRemoveFromAura(action.Discovered)
			elif action is StatAction:
				onCheckAllyStats(action.getCards())
				
		if action is DeathAction:
			if action.Defender in affected_cards:
				onRemoveFromAura(action.Defender)
			elif action.Defender == self:
				for Card: CardGD in affected_cards.duplicate():
					onRemoveFromAura(Card)

func getAttackBuff() -> int:
	return getTierAttackGain()
	
func onAddToAura(Card: CardGD) -> void:
	if Card == self: return
	Card.onCreateBaseFieldEffect(PALMFESSORS_STUDENT_ID, -1, -1, self)
	affected_cards.append(Card)
	onPushAction(StatAction.new(StatInfo.new(Card, Game.Stats.ATTACK, getAttackBuff(), 0, false, true, true)))
	
func onRemoveFromAura(Card: CardGD) -> void:
	if Card not in affected_cards: return
	Card.onRemoveFieldEffectsByOwner(self)
	affected_cards.erase(Card)
	onPushAction(StatAction.new(StatInfo.new(Card, Game.Stats.ATTACK, -getAttackBuff(), 0, false, true, true)))
	
func onCheckAllyStats(cards: Array) -> void:
	var ally_field_cards: Array = getVisibleFieldCardsAllies()
	var attack_gain: int = getTierAttackGain()
	
	for Card: CardGD in cards.filter(func(x: CardGD): return x in ally_field_cards):
		if Card.getAttack() == 1 and Card not in affected_cards:
			onAddToAura(Card)
		elif Card.getAttack() != (1 + attack_gain) and Card in affected_cards:
			onRemoveFromAura(Card)

func onSave() -> SavedDataCard:
	ability_save['affected_cards'] = affected_cards.map(func(x: CardGD): return x.public_id)
	return super()
	
func onLoadData(data: SavedData) -> void:
	super(data)
	affected_cards = affected_cards.map(func(id: int): return Game.onFindPublicIDObject(id))

func isValidEliteLevelSpawns(enemy_cards: Array) -> bool:
	var one_attack_amount: int = enemy_cards.filter(func(x: SavedDataCard): return x.attack == 1).size()
	return one_attack_amount >= 2
	
func onRetiered(_tier: int) -> void:
	var old_tier: int = tier
	super(_tier)
	if old_tier == tier: return
	
	var new_attack: int = 1 + getTierAttackGain()
	onPushAction(StatAction.new(affected_cards.map(func(x: CardGD): return StatInfo.new(x, Game.Stats.ATTACK, new_attack - x.getAttack(), 0, false, true, true))))

func onReset(override: bool = false) -> void:
	super(override)
	affected_cards = []

func getTierAttackGain(_tier: int = tier) -> int:
	match _tier:
		1: return TIER_ONE_ATTACK_GAIN
		2: return TIER_TWO_ATTACK_GAIN
		3: return TIER_THREE_ATTACK_GAIN
		4: return TIER_FOUR_ATTACK_GAIN
	return 0
