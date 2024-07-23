extends StatusFXGD

var armor: int = 0
func onAfterSetInfo(_armor: int) -> void:
	armor = _armor
	
func getTooltip() -> String:
	return info.tooltip.replace("[X]", "[" + str(armor) + "]")
