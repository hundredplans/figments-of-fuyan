class_name AddToDeckAction extends Action

var Card: CardGD

func _init(_Card: CardGD = null) -> void:
	super()
	Card = _Card

func onPreAction() -> void:
	pass

func onPostAction() -> void:
	var energy_limit: int = Game.getSaveFile().getEnergyLimit()
	var deck_limit: int = Game.getSaveFile().getDeckLimit()
	var is_available: bool = Game.getSaveFile().isCardValidForDeck(Card)
	
	if is_available:
		var deck_slot: DeckSlot = Game.getSaveFile().getFirstAvailableDeckSlot()
		if deck_slot != null:
			deck_slot.onAddCard(Card)
	else:
		Card.onChangeCardPlace(Game.CardPlaces.STASH)
	
	Card.team = 0
	Card.add_to_group("AllyCardsGD")
	Card.reparent(Game.getSaveFile())
	
	#if add_type == ADD_TYPES.SHUFFLE:
		#var deck_cards: Array = Game.get_tree().get_nodes_in_group("DeckCardsGD")
		#deck_cards.insert(randi_range(0, deck_cards.size()), Card)
		#deck_cards.shuffle()
		#for i in range(deck_cards.size()):
			#deck_cards[i].draw_order = i
