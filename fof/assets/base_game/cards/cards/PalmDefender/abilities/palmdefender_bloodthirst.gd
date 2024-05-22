extends BloodthirstGD

@export var HEALTH: int = 1
func onBloodthirst() -> void:
	onGainStats(Unit, "health", HEALTH, AppliedBy)

func onBloodthirstCondition() -> bool:
	return AppliedBy.Applier != null and AppliedBy.Applier.base_card.area_id == 1
