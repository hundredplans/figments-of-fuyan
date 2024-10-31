extends ToolGD

var visible_cards: Array = []
func onProcessAction(action: Action) -> void:
	super(action)
	if !action.post:
		if action is DamageAction and action.owner is AttackAction:
			for Defender in action.owner.Defenders.filter(func(x: GameObjectGD): return x is CardGD and x.isInjured()):
				if action.owner.Attacker == Card or (ascended and action.owner.Attacker.isAlly(Card.team) and action.owner.Attacker in visible_cards):
					action.damage += 1
	elif action.post:
		if action is VisionNewUnitAction and action.Discoverer == Card:
			if action.enter_vision: onAddFieldEffect(action.Discovered)
			else: onRemoveFieldEffect(action.Discovered)
		elif action is DeathAction and action.Defender == Card:
			onRemoveFieldEffects(action.game_objects_in_vision.filter(func(x: GameObjectGD): return x is CardGD and x.isAlly(Card.team)))

func onToolEquipped() -> void:
	if ascended:
		for FieldCard in Card.getVisibleFieldCardsAllies():
			onAddFieldEffect(FieldCard)
	
func onToolUnequipped() -> void:
	super()
	onRemoveFieldEffects(Card.getVisibleFieldCardsAllies())
	
func onRemoveFieldEffects(visible_field_cards: Array) -> void:
	if ascended:
		for FieldCard in visible_field_cards:
			onRemoveFieldEffect(FieldCard)
	
func onAddFieldEffect(FieldCard: CardGD) -> void:
	var FieldEffect: FieldEffectGD = SavedData.onLoadModel(SavedDataFieldEffect.new(1, true), FieldCard)
	FieldCard.onAddFieldEffect(FieldEffect, self)
	visible_cards.append(FieldCard)
	
func onRemoveFieldEffect(FieldCard: CardGD) -> void:
	FieldCard.onRemoveFieldEffectsByOwner(self)
	visible_cards.erase(FieldCard)
	
func onSave() -> SavedDataTool:
	ability_save['visible_cards'] = visible_cards.map(func(x: CardGD): return x.public_id)
	return super()
	
func onLoadData(data: SavedData) -> void:
	super(data)
	visible_cards = visible_cards.map(func(id: int): return Game.onFindPublicIDObject(id))
