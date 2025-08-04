
extends BoonGD

const TIER_ONE_SPEED_GAIN: int = 1
const TIER_TWO_SPEED_GAIN: int = 2
const TIER_THREE_SPEED_GAIN: int = 2
const TIER_FOUR_SPEED_GAIN: int = 2

const TIER_ONE_TURNS: int = 1
const TIER_TWO_TURNS: int = 1
const TIER_THREE_TURNS: int = 2
const TIER_FOUR_TURNS: int = 3

const ENERGIZED_BOON_FIELD_EFFECT_ID: int = 9

func onProcessAction(action: Action) -> void:
	super(action)
	if action.post:
		if action is AwakenAction and action.Card.isAlly(0):
			onPushAction(BoonActivatedAction.new(self, action))

func onBoon(action: Action = null) -> void:
	var speed: int = getSpeedGain()
	var turns: int = getTurns() + 1 # +1 because awakened
	onPushAction(StatAction.new(StatInfo.new(action.Card, Game.Stats.MAX_SPEED, speed, turns)))
	
	var FieldEffect: FieldEffectGD = action.Card.onCreateBaseFieldEffect(ENERGIZED_BOON_FIELD_EFFECT_ID, -1, turns)
	FieldEffect.setSpeed(speed)

func getTurns() -> int:
	match tier:
		1: return TIER_ONE_TURNS
		2: return TIER_TWO_TURNS
		3: return TIER_THREE_TURNS
		4: return TIER_FOUR_TURNS
	return 0
	
func getSpeedGain() -> int:
	match tier:
		1: return TIER_ONE_SPEED_GAIN
		2: return TIER_TWO_SPEED_GAIN
		3: return TIER_THREE_SPEED_GAIN
		4: return TIER_FOUR_SPEED_GAIN
	return 0
