extends MapEffectGD

var NewCard: CardGD
func onPickup(Card: CardGD) -> void:
	Card.onAscend(true)
	NewCard = Card
