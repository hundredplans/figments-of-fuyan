extends StatusEffectGD

func onProcessAction(action: Action) -> void:
	super(action)
	if !action.post:
		if action is DamageAction and action.owner != null and action.owner is AttackAction:
			action.setFatal(true)

func getDescription() -> String:
	return Helper.getDescription(super(), [turns])
