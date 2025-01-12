extends StatusEffectGD

func onStatusEffectAdded(_action: AddStatusEffectAction) -> void:
	onPushAction(VisionAction.new(Card))

func onProcessAction(action: Action) -> void:
	super(action)
	
func onClear() -> void:
	super()
	onPushAction(VisionAction.new(Card))

func getDescription() -> String:
	return Helper.getDescription(super(), [turns])
