extends ToolGD

const STICK_EXTRA_DAMAGE: int = 1
func onProcessAction(action: Action) -> void:
	super(action)
	if !action.post:
		if action is DamageAction and action.owner is AttackAction and action.owner.Attacker == Card:
			onForceAction(ToolActivatedAction.new(self, action))
	elif action.post:
		if action is GetDamageAction and action.Damager == Card and !action.is_fall_damage:
			action.onAdd(STICK_EXTRA_DAMAGE)
	
func onToolAction(action: DamageAction) -> void:
	action.damage += STICK_EXTRA_DAMAGE
	onPushAction(RemoveToolAction.new(Card))
	
func onToolEquipped() -> void:
	pass
	
func onToolUnequipped() -> void:
	super()
