extends StatusEffectGD

func onFofInit() -> void:
	onPushAction(VisionAction.new(Card))

func onProcessAction(action: Action) -> void:
	super(action)
	if !action.post:
		if action is VisionAction and action.Card == Card:
			action.new_card_visible_game_objects = action.new_card_visible_game_objects.filter(func(x: GameObjectGD): return x.isAdjacent(Card.getCoords()))
	
func onClear() -> void:
	super()
	onPushAction(VisionAction.new(Card))
