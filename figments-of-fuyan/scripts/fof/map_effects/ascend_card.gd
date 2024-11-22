extends MapEffectGD

func onPickup(Card: CardGD) -> void:
	Card.onAscend()
