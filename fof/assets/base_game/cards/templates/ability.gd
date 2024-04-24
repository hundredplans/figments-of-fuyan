class_name AbilityGD
extends Resource

var Combat: CombatGD
var Tiles: TilesGD
var Units: UnitsGD
var Vision: VisionGD

func onGainStats(Unit: UnitGD, stat_type: String, val: int, AppliedBy: AppliedByGD) -> void:
	if val > 0: Unit.stats(stat_type, val, AppliedBy)
	else: print_debug("You are gaining negative stats!")
