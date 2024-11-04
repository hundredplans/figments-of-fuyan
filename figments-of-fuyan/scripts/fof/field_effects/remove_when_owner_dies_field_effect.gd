class_name RemoveWhenOwnerDiesFieldEffectGD extends FieldEffectGD

func onProcessAction(action: Action) -> void:
	if action.post:
		if action is DeathAction and action.Defender == FofObject:
			onRemoveFromCard()
