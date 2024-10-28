extends FieldEffectGD

var speed: int
var turns: int

func getDescription() -> String:
	return Helper.getDescriptionNumeric(super(), [speed, turns], [["This has ", "[1]"], ["for ", "[1]"]])

func onSave() -> SavedDataFieldEffect:
	ability_save['speed'] = speed
	ability_save['turns'] = turns
	return super()
