extends ToolGD

const STICK_EXTRA_DAMAGE: int = 1
func onProcessAction(action: Action) -> void:
	super(action)
	if !action.post:
		if action is DamageAction and action.owner is AttackAction and action.owner.Attacker == Card:
			onForceAction(ToolActivatedAction.new(self, action))
		elif action is GetDamageAction and action.Damager == Card and action.damage_type == Game.DamageTypes.ATTACK:
			action.onAdd(STICK_EXTRA_DAMAGE)
	
func onToolAction(action: DamageAction) -> void:
	action.damage += STICK_EXTRA_DAMAGE
	onPushAction(RemoveToolAction.new(Card))
	
func onToolEquipped() -> void:
	super()
	
func onToolUnequipped() -> void:
	super()
	
func onToolHolderAwakened() -> void:
	super()
	
func onToolHolderDeath() -> void:
	super()
