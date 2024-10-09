extends StatusEffectGD

func onProcessAction(action: Action) -> void:
	if !action.post:
		if action is VisionAction and action.Card.isEnemy(Card.team):
			if Card in action.new_card_visible_game_objects and !Card.isAdjacent(action.Card.getCoords()):
				action.new_card_visible_game_objects.erase(Card)
 	
