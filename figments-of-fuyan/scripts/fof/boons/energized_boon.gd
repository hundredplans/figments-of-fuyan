
extends BoonGD

const ENERGIZED_BOON_FIELD_EFFECT_ID: int = 9

func onProcessAction(action: Action) -> void:
	super(action)
	if action.post:
		if action is AwakenAction and action.Card.isAlly(0):
			onPushAction(BoonActivatedAction.new(self, action))

func onBoon(action: Action = null) -> void:
	var speed: int = 1 if tier == 1 else 2
	var turns: int = 2 # Has to be 2 because they get awakened
	onPushAction(StatAction.new(StatInfo.new(action.Card, Game.Stats.MAX_SPEED, speed, turns)))
	
	var FieldEffect: FieldEffectGD = action.Card.onCreateBaseFieldEffect(ENERGIZED_BOON_FIELD_EFFECT_ID, -1, turns)
	FieldEffect.setSpeed(speed)
