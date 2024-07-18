extends BloodthirstGD

@export var HEALTH: int = 1
func onBloodthirst() -> void:
	Units.changeStats(StatInfoGD.new(Unit, AppliedBy, StatsGD.BOTH_HEALTH, HEALTH))

func onBloodthirstCondition() -> bool:
	return AppliedBy.Applier != null and AppliedBy.Applier.base_card.area_id == 1
