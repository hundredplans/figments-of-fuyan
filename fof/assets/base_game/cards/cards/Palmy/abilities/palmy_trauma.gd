extends TraumaGD

func onTrauma(_is_visible: bool, Unit: UnitGD, AppliedBy: AppliedByGD) -> void:
	onGainStats(Unit, "speed", 1, AppliedBy)
	charges -= 1
	
func onTraumaCondition() -> bool:
	return charges > 0
