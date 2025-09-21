class_name HandCardAction extends Action # Used to insert / add to your hand

const HAND_CARD_DELAY: float = 2.0
var Card: CardGD
func _init(_Card: CardGD = null) -> void:
	super()
	Card = _Card
	setActionDelay(HAND_CARD_DELAY)
	
func onPostAction() -> void:
	Card.onChangeCardPlace(Game.CardPlaces.HAND)
