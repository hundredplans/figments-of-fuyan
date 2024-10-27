extends ToolGD

func onProcessAction(action: Action) -> void:
	super(action)
	if !action.post and action is DamageAction and action.owner is AttackAction and action.owner.Attacker == Card:
		action.damage += 1
		onPushAction(RemoveToolAction.new(Card))
	
func onToolEquipped() -> void:
	pass
	
func onToolUnequipped() -> void:
	super()
