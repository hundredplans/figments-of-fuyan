extends FieldEffectGD

func getDescription() -> String:
	var replace_number: String = "2" if !FofObject.ascended else "4"
	return Helper.getDescriptionNumeric(super(), [replace_number], [["deal ", "[2]"]])
