class_name RevengeGD
extends AbilityGD

const type: String = "Revenge"
@export var trigger_on_death: bool = true

var Unit: UnitGD
var DMGInfo: DMGInfoGD
var AppliedBy: AppliedByGD
var damage: int

func setInfo(_Unit: UnitGD = null, _DMGInfo: DMGInfoGD = null, _AppliedBy: AppliedByGD = null, _damage: int = 1) -> void:
	Unit = _Unit
	DMGInfo = _DMGInfo
	AppliedBy = _AppliedBy
	damage = _damage
