class_name DMGInfoGD
extends Resource

var BaseDMG: int
var HealthDMG: int
var Defender: UnitGD
@export var AppliedBy: AppliedByGD

func _init(_Defender: UnitGD = null, _AppliedBy: AppliedByGD = null, dmg: int = 1, hp_dmg: int = 0) -> void:
	BaseDMG = dmg
	AppliedBy = _AppliedBy
	Defender = _Defender
	HealthDMG = hp_dmg
