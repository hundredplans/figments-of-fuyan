extends BloodthirstGD

func onBloodthirst(_is_visible: bool, Unit: UnitGD, _AppliedBy: AppliedByGD) -> void:
	var AppliedBy := AppliedByGD.new()
	AppliedBy.type = "Ability"
	AppliedBy.Applier = Unit
	onGainStats(Unit, "health", 1, AppliedBy)

func onBloodthirstCondition(_Deather: UnitGD, AppliedBy: AppliedByGD, Unit: UnitGD) -> bool:
	if AppliedBy.type != "Height":
		if AppliedBy.Applier != Unit and AppliedBy.Applier.base_card.area_id == 1:
			return true
	return false
