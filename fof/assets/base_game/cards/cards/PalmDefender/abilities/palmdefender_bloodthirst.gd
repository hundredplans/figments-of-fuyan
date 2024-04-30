extends BloodthirstGD

@export var HEALTH: int = 1
func onBloodthirst(a: Dictionary) -> void:
	var AppliedBy := AppliedByGD.new()
	AppliedBy.type = "Ability"
	AppliedBy.Applier = a.Unit
	onGainStats(a.Unit, "health", HEALTH, a.AppliedBy)

func onBloodthirstCondition(a: Dictionary) -> bool:
	if a.AppliedBy.type != "Height":
		if a.AppliedBy.Applier != a.Unit and a.AppliedBy.Applier.base_card.area_id == 1:
			return true
	return false
