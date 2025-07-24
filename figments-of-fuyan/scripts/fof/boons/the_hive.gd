extends BoonGD

const HIVE_AMOUNT: int = 2
const HIVE_FIELD_EFFECT_ID: int = 12
func onProcessAction(action: Action):
	super(action)
	if action.post:
		if action is DeathAction and action.Defender is CardGD and action.Defender.isAlly(1):
			onPushAction(BoonActivatedAction.new(self, action))
	
func onAscend(state: bool):
	super(state)
	
func onBoon(_action: DeathAction):
	var cards: Array = Game.getAllyUnits(1)
	cards.shuffle()
	cards.resize(HIVE_AMOUNT)
	cards = cards.filter(func(x: CardGD): return x != null)
	
	onPushAction(StatAction.new(cards.map(func(x: CardGD): return StatInfo.new(x, Game.Stats.ATTACK, 1))))
	
	for Card: CardGD in cards:
		var field_effect: FieldEffectGD = Card.getFirstFieldEffect(HIVE_FIELD_EFFECT_ID)
		if field_effect != null:
			field_effect.onIncrementAttack()
		else:
			field_effect = Card.onCreateBaseFieldEffect(HIVE_FIELD_EFFECT_ID)
			field_effect.onIncrementAttack()
			
func onBoonAdded():
	pass

func getDisabled():
	return super()
