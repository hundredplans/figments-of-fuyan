extends CardGD

func onProcessAction(action: Action) -> void:
	super(action)
	if isValidForceOnHit(action):
		onForceAction(OnHitAction.new(self, action))
	elif isValidOnHit(action):
		onPushAction(OnHitAction.new(self, action))
	
	if !action.post:
		if action is GetDamageAction:
			action.setIgnoreArmorShield(true)
	
func onHit(damage_action: DamageAction, _attack_action: AttackAction) -> void:
	if !damage_action.post: damage_action.setIgnoreArmorShield(true)
	elif damage_action.post and damage_action.isIgnoreArmorShieldSuccess():
		onPushAction(StatAction.new(StatInfo.new(self, Game.Stats.ATTACK, 1)))
