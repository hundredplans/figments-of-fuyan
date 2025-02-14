extends FieldEffectGD

var speed: int

func getDescription() -> String:
	return Helper.getDescription(super(), [speed, turns])

func onSave() -> SavedDataFieldEffect:
	ability_save['speed'] = speed
	return super()
