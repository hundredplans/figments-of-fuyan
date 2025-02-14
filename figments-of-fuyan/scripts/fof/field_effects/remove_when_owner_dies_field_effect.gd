class_name RemoveWhenOwnerDiesFieldEffectGD extends FieldEffectGD

func onProcessAction(action: Action) -> void:
	super(action)
	if action.post:
		if action is DeathAction and action.Defender == FofObject:
			onPushAction(RemoveFieldEffectAction.new(self))
