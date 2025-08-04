extends CardGD

const TIER_ONE_ATTACK: int = 1
const TIER_TWO_ATTACK: int = 2
const TIER_THREE_ATTACK: int = 2
const TIER_FOUR_ATTACK: int = 3

func onProcessAction(action: Action) -> void:
	super(action)
	if isValidArrive(action):
		onPushAction(ArriveAction.new(self, action))
	elif action.post and action is RemoveFieldEffectAction\
	and action.FieldEffect.info.id == SHIELD_ID and action.FieldEffect.Card == self:
		onShieldLost()

func onArrivePre(_action: AwakenAction) -> void:
	pass

func onArrive(_action: AwakenAction) -> void:
	onAbility()
	onGainShield()
	
func onShieldLost() -> void:
	onAbility()
	onPushAction(StatAction.new(StatInfo.new(self, Game.Stats.ATTACK, getTierAttack())))

func getTierAttack() -> int:
	match tier:
		1: return TIER_ONE_ATTACK
		2: return TIER_TWO_ATTACK
		3: return TIER_THREE_ATTACK
		4: return TIER_FOUR_ATTACK
	return 0
