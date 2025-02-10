extends FieldEffectGD

func getDescription() -> String:
	return Helper.getDescription(super(), [Card.bullets, Card.getMaxBullets()])
