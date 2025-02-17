class_name AddToDeckAction extends Action

enum ADD_TYPES {SHUFFLE}
var add_type: ADD_TYPES
var Card: CardGD

func _init(_Card: CardGD = null, _add_type: ADD_TYPES = ADD_TYPES.SHUFFLE) -> void:
	super()
	Card = _Card
	add_type = _add_type

func onPostAction() -> void:
	Card.onChangeCardPlace(Game.CardPlaces.DECK)
	Card.team = 0
	Card.reparent(Game.getSaveFile())
	
	if add_type == ADD_TYPES.SHUFFLE:
		var deck_cards: Array = Game.get_tree().get_nodes_in_group("DeckCardsGD")
		deck_cards.insert(randi_range(0, deck_cards.size()), Card)
		for i in range(deck_cards.size()):
			deck_cards[i].draw_order = i
