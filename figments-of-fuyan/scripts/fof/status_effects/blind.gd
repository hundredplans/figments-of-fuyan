extends StatusEffectGD

func onProcessAction(action: Action) -> void:
	if !action.post:
		if action is VisionAction and action.Card == Card:
			action.new_card_visible_game_objects = action.new_card_visible_game_objects.filter(func(x: GameObjectGD): return x.isAdjacent(Card.getCoords()))
