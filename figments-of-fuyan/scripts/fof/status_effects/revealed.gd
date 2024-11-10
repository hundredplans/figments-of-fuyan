class_name RevealedGD extends StatusEffectGD

func onProcessAction(action: Action) -> void:
	super(action)

func onStatusEffectAdded(action: AddStatusEffectAction) -> void:
	onPushAction(RevealAction.new(Card, action.owner))

func onClear() -> void:
	super()
	onPushAction(RevealAction.new(Card, Card, false))

func getDescription() -> String:
	return Helper.getDescription(super(), [turns])
