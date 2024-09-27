extends Control

@onready var InspectSubviewport: SubViewport = %InspectSubviewport
@onready var CardSpot: Control = %CardSpot
@onready var FlavorTextLabel: Label = %FlavorTextLabel

var Card: CardGD
func setInfo(_Card: CardGD) -> void:
	Card = _Card
	Card.onCreateCardUI(CardSpot)
	FlavorTextLabel.text = Card.info.flavor_text
	InspectSubviewport.setInfo(Card)
