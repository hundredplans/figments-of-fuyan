extends StatusEffectGD

func onFofInit() -> void:
	onPushAction(InVisionResetAction.new(Card))

func onProcessAction(action: Action) -> void:
	super(action)
	if !is_queued_for_deletion() and !action.post and action is VisionAction and Card in action.new_card_visible_game_objects and !action.Card.isAlly(0) and !Card.isAdjacent(action.Card.getCoords()):
		action.new_card_visible_game_objects.erase(Card)
 	
func onClear() -> void:
	super()
	onPushAction(InVisionResetAction.new(Card))
