extends BoonGD

var cards: Array = []
func onProcessAction(action: Action) -> void:
	super(action)
	if action.post:
		if action is AwakenAction and action.Card.isAlly(0):
			onPushAction(BoonActivatedAction.new(self, action))
		elif action is ChangePhaseAction and Game.isAdvanceTurn(action.phase, 0):
			onFieldEffectsTurnPassed()
	
func onUpdateAscenscion() -> void:
	super()

func getDescription() -> String:
	return super()

func onBoon(action: Action = null) -> void:
	var speed: int = 1 if !ascended else 2
	var turns: int = 2 if !Game.isChampion(action.Card.info.rarity) else 1
	onPushAction(StatAction.new(StatInfo.new(action.Card, Game.Stats.MAX_SPEED, speed, turns)))
	
	var FieldEffect: FieldEffectGD = SavedData.onLoadModel(SavedDataFieldEffect.new(9, true, 0, public_id, {"speed": speed, "turns": turns}), action.Card)
	action.Card.onAddFieldEffect(FieldEffect, self)
	cards.append(action.Card)

func onBoonAdded() -> void:
	pass

func onSave() -> SavedDataBoon:
	ability_save['cards'] = cards.map(func(x: CardGD): return x.public_id)
	return super()
	
func onLoadData(data: SavedData) -> void:
	super(data)
	cards = cards.map(func(x: int): return Game.onFindPublicIDObject(x))
	
func onFieldEffectsTurnPassed() -> void:
	for FieldCard in cards:
		var field_effects: Array = FieldCard.onFindFieldEffectsByOwner(self)
		for FieldEffect in field_effects:
			FieldEffect.turns -= 1
			if FieldEffect.turns == 0:
				FieldCard.onRemoveFieldEffect(FieldEffect)
