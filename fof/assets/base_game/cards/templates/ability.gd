class_name AbilityGD
extends Resource

func onGainStats(Unit: UnitGD, stat_type: String, val: int, AppliedBy: Variant = "GameEvent") -> void:
	if val > 0: Unit.stats(stat_type, val, AppliedBy)
	else: print_debug("You are gaining negative stats!")
