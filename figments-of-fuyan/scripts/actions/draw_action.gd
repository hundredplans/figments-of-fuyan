class_name DrawAction extends Action

var Card: CardGD
func onPreAction() -> void:
	var deck_cards: Array = Game.get_tree().get_nodes_in_group("DeckCardsGD")
	if !deck_cards.is_empty():
		deck_cards.sort_custom(func(x: CardGD, y: CardGD): return x.draw_order < y.draw_order)
		Card = deck_cards[0]
		return
	onFailAction()
		
func onPostAction() -> void:
	Card.onChangeCardPlace(CardGD.CARD_PLACES.HAND)
