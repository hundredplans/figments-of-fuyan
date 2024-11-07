class_name VisionAction extends Action

var cards: Array
var new_visible_game_objects: Dictionary # Dict of {CardGD: visibles}

func _init(_cards: Variant) -> void:
	super()
	if _cards is CardGD: cards = [_cards]
	elif _cards is Array: cards = _cards
	
func onPreAction() -> void:
	for Card in cards:
		new_visible_game_objects[Card] = Card.onUpdateVision()
		
	var tile_to_card: Dictionary = {}
	
	for FieldCard in Game.get_tree().get_nodes_in_group("FieldCardsGD"):
		tile_to_card[FieldCard.Tile] = FieldCard
	
	
	for card_vision in new_visible_game_objects.values():
		for GameObject in card_vision:
			if GameObject is CardGD:
				card_vision[GameObject.Tile] = null
			elif GameObject is TileGD and tile_to_card.has(GameObject):
				card_vision[tile_to_card[GameObject]] = null
	
func onPostAction() -> void:
	var actions: Array = []
	var Discoverer: CardGD = cards[0]
	var old_team_vision: Array = Game.getTeamVision(0) if cards.any(func(x: CardGD): return x.isAlly(0)) else []
	
	for Card in cards:
		var card_visible_game_objects: Array = new_visible_game_objects[Card].keys()
		var old_visible_cards: Array = Card.visible_game_objects.filter(func(x: GameObjectGD): return x is CardGD)
		var new_visible_cards: Array = card_visible_game_objects.filter(func(x: GameObjectGD): return x is CardGD)
		
		Card.visible_game_objects = card_visible_game_objects
		
		var not_in_vision: Array = old_visible_cards.filter(func(x: CardGD): return x not in new_visible_cards)
		var now_in_vision: Array = new_visible_cards.filter(func(x: CardGD): return x not in old_visible_cards)
		
		actions += not_in_vision.map(func(x: CardGD): return VisionNewUnitAction.new(Card, x, false, old_team_vision))
		actions += now_in_vision.map(func(x: CardGD): return VisionNewUnitAction.new(Card, x, true, old_team_vision))
	
	if cards.any(func(x: CardGD): return x.isAlly(0)): # Checks whether to bother resetting level visible
		var new_team_vision: Array = Game.getTeamVision(0)
		
		var not_in_vision: Array = old_team_vision.filter(func(x: GameObjectGD): return x not in new_team_vision)
		var now_in_vision: Array = new_team_vision.filter(func(x: GameObjectGD): return x not in old_team_vision)
		
		actions += [LevelVisibleAction.new(false, not_in_vision), LevelVisibleAction.new(true, now_in_vision)]
	onPushAction(actions)
			
func getLogInfo() -> Array:
	return cards.map(func(x: CardGD): return "Card: " + x.info.name)
