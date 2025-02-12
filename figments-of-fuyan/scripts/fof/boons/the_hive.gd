extends BoonGD

const HIVE_FIELD_EFFECT_ID: int = 12
func onProcessAction(action: Action):
	super(action)
	if action.post:
		if action is DeathAction and action.Defender is CardGD and action.Defender.isAlly(1):
			onPushAction(BoonActivatedAction.new(self, action))
	
func onAscend(state: bool):
	super(state)

func getDescription():
	return super()
	
func onBoon(_action: DeathAction):
	var cards: Array = Game.getAllyUnits(1)
	onPushAction(StatAction.new(cards.map(func(x: CardGD): return StatInfo.new(x, Game.Stats.ATTACK, 1, 2))))
	
	for Card: CardGD in cards:
		var field_effect: FieldEffectGD = Card.getFirstFieldEffect(HIVE_FIELD_EFFECT_ID)
		if field_effect != null: field_effect.onIncrementTwoTurnAmount()
		else:
			field_effect = Card.onAddBaseFieldEffect(HIVE_FIELD_EFFECT_ID, Card)
			field_effect.onIncrementTwoTurnAmount()
			
func onBoonAdded():
	pass

func getDisabled():
	return super()

func getCharges():
	return super()
