class_name DisarmGD extends StatusEffectGD

func onProcessAction(action: Action) -> void:
	super(action)
	if !action.post:
		if action is ChangeAttacksAction and action.Card == Card:
			action.attacks = 0
	
func getDescription() -> String:
	return Helper.getDescription(super(), [turns])
	
func onStatusEffectAdded(_action: AddStatusEffectAction) -> void:
	onPushAction(ChangeAttacksAction.new(Card, 0))
