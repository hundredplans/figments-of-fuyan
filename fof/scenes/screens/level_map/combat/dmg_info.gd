class_name DMGInfoGD
extends Resource

var BaseDMG: int
var HealthDMG: int
var Defender: Variant
@export var AppliedBy: AppliedByGD

func _init(_Defender: Variant = null, _AppliedBy: AppliedByGD = null, dmg: int = 1, hp_dmg: int = 0) -> void:
	BaseDMG = dmg
	AppliedBy = _AppliedBy
	Defender = _Defender
	HealthDMG = hp_dmg

func getAttacker() -> UnitGD:
	if AppliedBy.Applier is UnitGD:
		return AppliedBy.Applier
	return null
