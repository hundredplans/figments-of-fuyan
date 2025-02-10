class_name VisionAction extends Action

var cards: Array
var ExplorerCard: CardGD # Card that occupy action caused the vision action

var old_visible_game_objects: Dictionary
var new_visible_game_objects: Dictionary # Dict of {CardGD: visibles}
var old_team_vision: Array

func _init(_cards: Variant = null, _ExplorerCard: CardGD = null) -> void:
	super()
	if _cards is CardGD: cards = [_cards]
	elif _cards is Array: cards = _cards
	ExplorerCard = _ExplorerCard
	
func onPreAction() -> void:
	old_team_vision = Game.getLevel().old_player_vision.duplicate()
	
	for Card in cards:
		old_visible_game_objects[Card] = Card.getVisibleGameObjects()
		Card.onUpdateVision()
		new_visible_game_objects[Card] = Card.getVisibleGameObjects()
	
func onPostAction() -> void:
	var actions: Array = []
	
	var new_team_vision_dict: Dictionary = Game.getTeamVisionDictionary(0)
	setRevealedGameObjects(new_team_vision_dict)
	
	var new_team_vision: Array = new_team_vision_dict.keys()
	Game.getLevel().old_player_vision = new_team_vision.duplicate()
	
	var new_team_vision_diff: Array = new_team_vision.filter(func(x: GameObjectGD): return x not in old_team_vision)
	var old_team_vision_diff: Array = old_team_vision.filter(func(x: GameObjectGD): return (x not in new_team_vision) and !(x is CardGD and !x.isAlive()))
	
	for Card in cards:
		var old_visible_cards: Array = old_visible_game_objects[Card].filter(func(x: GameObjectGD): return x is CardGD)
		var new_visible_cards: Array = new_visible_game_objects[Card].filter(func(x: GameObjectGD): return x is CardGD)
		
		var not_in_vision: Array = old_visible_cards.filter(func(x: CardGD): return x not in new_visible_cards)
		var now_in_vision: Array = new_visible_cards.filter(func(x: CardGD): return x not in old_visible_cards)
		
		actions += not_in_vision.map(func(x: CardGD): return VisionNewUnitAction.new(Card, x, false, old_team_vision))
		actions += now_in_vision.map(func(x: CardGD): return VisionNewUnitAction.new(Card, x, true, old_team_vision))
	
	actions.append(LevelVisibleAction.new(false, old_team_vision_diff))
	actions.append(LevelVisibleAction.new(true, new_team_vision_diff))
	
	var exit_level_visible_cards: Array = old_team_vision_diff.filter(func(x: GameObjectGD): return x is CardGD)
	if !exit_level_visible_cards.is_empty(): actions.append(ExitLevelVisibleAction.new(exit_level_visible_cards))
	
	onPushAction(actions)
			
func getLogInfo() -> Array:
	return cards.map(func(x: CardGD): return "Card: " + x.info.name)

func setRevealedGameObjects(new_team_vision_dict: Dictionary) -> void:
	var all_cards: Array = Game.get_tree().get_nodes_in_group("FieldCardsGD")
	var tile_to_card: Dictionary = {}
	
	for FieldCard in all_cards:
		tile_to_card[FieldCard.Tile] = FieldCard
		
	for GameObject in (Game.get_tree().get_nodes_in_group("LevelTileObjectsGD") + all_cards)\
		.filter(func(x: GameObjectGD): return x.isRevealed(0)):
			new_team_vision_dict[GameObject] = null
			if GameObject is TileGD and tile_to_card.has(GameObject):
				new_team_vision_dict[tile_to_card[GameObject]] = null
