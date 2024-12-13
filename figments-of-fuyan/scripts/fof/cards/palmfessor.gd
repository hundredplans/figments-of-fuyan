extends CardGD

var affected_cards: Array = []
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
				onCheckAllyStats()
		
		if action is DeathAction and action.Defender == self:
			for Card in affected_cards.duplicate(): onRemoveFromAura(Card)

func getAttackBuff() -> int:
	return 1 if !ascended else 2
	
func onAddToAura(Card: CardGD) -> void:
	if Card != self:
		Card.onAddBaseFieldEffect(6, self)
		affected_cards.append(Card)
		onPushAction(StatAction.new(StatInfo.new(Card, Game.Stats.ATTACK, getAttackBuff(), 0, false, true, true)))
	
func onRemoveFromAura(Card: CardGD) -> void:
	Card.onRemoveFieldEffectsByOwner(self)
	affected_cards.erase(Card)
	onPushAction(StatAction.new(StatInfo.new(Card, Game.Stats.ATTACK, -getAttackBuff(), 0, false, true, true)))
	
func onCheckAllyStats() -> void:
	var ally_field_cards: Array = getVisibleFieldCardsAllies()
	for Card in ally_field_cards:
		if Card.attack == 1 and Card not in affected_cards: onAddToAura(Card)
		elif Card.attack != (1 + getAttackBuff()) and Card in affected_cards: onRemoveFromAura(Card)
	
func getDescription() -> String:
	return super()

func onSave() -> SavedDataCard:
	ability_save['affected_cards'] = affected_cards.map(func(x: CardGD): return x.public_id)
	return super()
	
func onLoadData(data: SavedData) -> void:
	super(data)
	affected_cards = affected_cards.map(func(id: int): return Game.onFindPublicIDObject(id))

func isValidEliteLevelSpawns(enemy_spawns: Array) -> bool:
	var one_attack_amount: int = enemy_spawns.filter(func(x: SavedDataCard): return x.attack == 1).size()
	return one_attack_amount >= 2
