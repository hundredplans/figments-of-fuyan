extends CardGD

var affected_cards: Array = []
const PALMFESSORS_STUDENT_ID: int = 6

const TIER_ONE_ATTACK_GAIN: int = 1
const TIER_TWO_ATTACK_GAIN: int = 2
const TIER_THREE_ATTACK_GAIN: int = 2
const TIER_FOUR_ATTACK_GAIN: int = 3

const TIER_ONE_MINIMUM_ATTACK: int = 1
const TIER_TWO_MINIMUM_ATTACK: int = 1
const TIER_THREE_MINIMUM_ATTACK: int = 2
const TIER_FOUR_MINIMUM_ATTACK: int = 2

func onProcessAction(action: Action) -> void:
	super(action)
	if action.post:
		if card_place == Game.CardPlaces.FIELD:
			if action is VisionNewUnitAction and action.Discoverer == self and action.Discovered.isAlly(team):
				if action.enter_vision and action.Discovered.attack <= getTierMinimumAttack():
					onAddToAura(action.Discovered)
				elif !action.enter_vision and action.Discovered in affected_cards:
					onRemoveFromAura(action.Discovered)
			elif action is StatAction:
				onCheckAllyStats()
		
		if action is DeathAction and action.Defender == self:
			for Card in affected_cards.duplicate(): onRemoveFromAura(Card)

func getAttackBuff() -> int:
	return getTierAttackGain()
	
func onAddToAura(Card: CardGD) -> void:
	if Card != self:
		Card.onCreateBaseFieldEffect(PALMFESSORS_STUDENT_ID, -1, -1, self)
		affected_cards.append(Card)
		onPushAction(StatAction.new(StatInfo.new(Card, Game.Stats.ATTACK, getAttackBuff(), 0, false, true, true)))
	
func onRemoveFromAura(Card: CardGD) -> void:
	Card.onRemoveFieldEffectsByOwner(self)
	affected_cards.erase(Card)
	onPushAction(StatAction.new(StatInfo.new(Card, Game.Stats.ATTACK, -getAttackBuff(), 0, false, true, true)))
	
func onCheckAllyStats() -> void:
	var ally_field_cards: Array = getVisibleFieldCardsAllies()
	var min_attack: int = getTierMinimumAttack()
	var attack_gain: int = getTierAttackGain()
	
	for Card in ally_field_cards:
		if Card.attack <= min_attack and Card not in affected_cards: onAddToAura(Card)
		elif Card.attack not in [1 + attack_gain, 2 + attack_gain] and Card in affected_cards: onRemoveFromAura(Card)

func onSave() -> SavedDataCard:
	ability_save['affected_cards'] = affected_cards.map(func(x: CardGD): return x.public_id)
	return super()
	
func onLoadData(data: SavedData) -> void:
	super(data)
	affected_cards = affected_cards.map(func(id: int): return Game.onFindPublicIDObject(id))

func isValidEliteLevelSpawns(enemy_cards: Array) -> bool:
	var min_attack: int = getTierMinimumAttack()
	var one_attack_amount: int = enemy_cards.filter(func(x: SavedDataCard): return x.attack <= min_attack).size()
	return one_attack_amount >= 2
	
#func onAscendedUpdated(state: bool) -> void:
	#super(state)
	#var mult: int = 1 if state else -1
	#for Card in affected_cards:
		#onPushAction(StatAction.new(StatInfo.new(Card, Game.Stats.ATTACK, 1 * mult,  0, false, true, true)))

func onRegularReset() -> void:
	super()
	affected_cards = []

func getTierAttackGain() -> int:
	match tier:
		1: return TIER_ONE_ATTACK_GAIN
		2: return TIER_TWO_ATTACK_GAIN
		3: return TIER_THREE_ATTACK_GAIN
		4: return TIER_FOUR_ATTACK_GAIN
	return 0
	
func getTierMinimumAttack() -> int:
	match tier:
		1: return TIER_ONE_MINIMUM_ATTACK
		2: return TIER_TWO_MINIMUM_ATTACK
		3: return TIER_THREE_MINIMUM_ATTACK
		4: return TIER_FOUR_MINIMUM_ATTACK
	return 0
