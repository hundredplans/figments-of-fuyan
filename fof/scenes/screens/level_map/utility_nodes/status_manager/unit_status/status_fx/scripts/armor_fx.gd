extends StatusFXGD

var armor: int = 0
	
func getTooltip() -> String:
	return info.tooltip.replace("[X]", "[" + str(armor) + "]")

func onReady() -> void:
	armor = AppliedBy.Applier.armor
