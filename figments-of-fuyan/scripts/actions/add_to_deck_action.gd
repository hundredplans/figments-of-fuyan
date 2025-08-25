class_name AddToDeckAction extends Action

var Card: CardGD
var override_deck_slot: DeckSlot

func _init(_Card: CardGD = null, _override_deck_slot: DeckSlot = null) -> void:
	super()
	Card = _Card
	override_deck_slot = _override_deck_slot

func onPreAction() -> void:
	pass

func onPostAction() -> void:
	if Game.getSaveFile().isCardValidForDeck(Card) or override_deck_slot != null:
		var deck_slot: DeckSlot = Game.getSaveFile().getFirstAvailableDeckSlot()\
			if override_deck_slot == null else override_deck_slot
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
