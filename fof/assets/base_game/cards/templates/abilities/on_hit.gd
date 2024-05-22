class_name OnHitGD
extends AbilityGD

const type: String = "OnHit"
var Unit: UnitGD
var DMGInfo: DMGInfoGD

func setInfo(_Unit: UnitGD = null, _DMGInfo: DMGInfoGD = null) -> void:
	Unit = _Unit
	DMGInfo = _DMGInfo
