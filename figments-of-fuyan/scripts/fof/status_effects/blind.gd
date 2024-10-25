extends StatusEffectGD

func onFofInit() -> void:
	onPushAction(VisionAction.new(Card))

func onProcessAction(action: Action) -> void:
	super(action)
	if !action.post:
		if !is_queued_for_deletion() and action is VisionAction and Card in action.cards:
			action.new_visible_game_objects[Card] = action.new_visible_game_objects[Card].filter(func(x: GameObjectGD): return x.isAdjacent(Card.getCoords()))
	
func onClear() -> void:
	super()
	onPushAction(VisionAction.new(Card))

func getDescription() -> String:
	return Helper.getDescription(super(), [turns])
