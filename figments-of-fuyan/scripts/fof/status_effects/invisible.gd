extends StatusEffectGD

func onStatusEffectAdded(action: AddStatusEffectAction) -> void:
	super(action)
	onPushAction(VisionAction.new(Game.inVisionRangeCards(Card.Tile)))

func onProcessAction(action: Action) -> void:
	super(action)
	if action.post:
		if action is MoveToTileAction and action.Card == Card:
			onClear(true)
 	
func onClear(ignore_reset: bool = false) -> void:
	super()
	if ignore_reset:
		onPushAction(VisionAction.new(Game.inVisionRangeCards(Card.Tile)))

func getDescription() -> String:
	return Helper.getDescription(super(), [turns])
