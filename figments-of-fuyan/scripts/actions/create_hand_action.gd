class_name CreateHandAction extends Action

const CREATE_HAND_DELAY: float = 2.0
var cards: Array

func onPreAction() -> void:
	var deck_slots: Array = Game.getSaveFile().getDeckSlots()\
		.filter(func(x: DeckSlot): return x.getCard() != null)
	cards = deck_slots.map(func(x: DeckSlot): return x.getCard())
	for Card: CardGD in cards:
		Card.add_to_group("AllyCardsGD")
		Card.onChangeCardPlace(Game.CardPlaces.HAND)

	Game.getLevel().setHandCards(cards)
	setActionDelay(CREATE_HAND_DELAY * cards.size())

func onPostAction() -> void:
	pass

func getCards() -> Array: return cards
