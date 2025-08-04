extends FieldEffectGD

func getDescription() -> String:
	return Helper.getDescription(super(), [owner.getTierAttackGain()])
