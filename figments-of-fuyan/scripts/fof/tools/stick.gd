extends ToolGD

const TIER_ONE_STICK_DAMAGE: int = 1
const TIER_TWO_STICK_DAMAGE: int = 2
const TIER_THREE_STICK_DAMAGE: int = 3
const TIER_FOUR_STICK_DAMAGE: int = 4

func onProcessAction(action: Action) -> void:
	super(action)
	if !action.post:
		if action is DamageAction and action.owner is AttackAction and action.owner.Attacker == Card:
			onForceAction(ToolActivatedAction.new(self, action))
		elif action is GetDamageAction and action.Damager == Card and action.damage_type == Game.DamageTypes.ATTACK:
			action.onAdd(getStickDamage())
	
func onToolAction(action: DamageAction) -> void:
	action.damage += getStickDamage()
	onPushAction(RemoveToolAction.new(Card))
	
func getStickDamage() -> int:
	match tier:
		1: return TIER_ONE_STICK_DAMAGE
		2: return TIER_TWO_STICK_DAMAGE
		3: return TIER_THREE_STICK_DAMAGE
		4: return TIER_FOUR_STICK_DAMAGE
	return 0
