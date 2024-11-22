extends MapEffectGD

func onPickup(Card: CardGD) -> void:
	Card.queue_free()
	
