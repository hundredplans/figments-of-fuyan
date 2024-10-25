extends StatusEffectGD

func onFofInit() -> void:
	onPushAction(VisionAction.new(Game.inVisionCards(Card.getCoords())))

func onProcessAction(action: Action) -> void:
	super(action)
	if !is_queued_for_deletion():
		if !action.post:
			if action is VisionAction:
				for VisionCard in action.new_visible_game_objects:
					for GameObject in action.new_visible_game_objects[VisionCard].keys():
						if GameObject == Card and !Card.isAdjacent(VisionCard.getCoords()):
							action.new_visible_game_objects[VisionCard].erase(Card)
							break
		else:
			if action is MoveToTileAction and action.Card == Card:
				onClear(true)
 	
func onClear(ignore_reset: bool = false) -> void:
	super()
	if ignore_reset:
		onPushAction(VisionAction.new(Game.inVisionCards(Card.getCoords())))

func getDescription() -> String:
	return Helper.getDescription(super(), [turns])
