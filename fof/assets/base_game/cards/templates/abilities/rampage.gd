class_name RampageGD
extends AbilityGD

const type: String = "Rampage"
var Unit: UnitGD
var AppliedBy: AppliedByGD

func setInfo(_Unit: UnitGD = null, _AppliedBy: AppliedByGD = null) -> void:
	Unit = _Unit
	AppliedBy = _AppliedBy
