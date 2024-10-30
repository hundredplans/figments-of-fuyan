class_name IObjectGD extends ObjectGD

func getValidAbilityEffects(Card: CardGD) -> Array: # Returns the ability effects the Card can view
	return []

func onProcessAction(action: Action) -> void:
	if action.post:
		if action is OccupyAction:
			pass
