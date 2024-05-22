class_name BloodthirstGD
extends AbilityGD

const type: String = "Bloodthirst"
var Unit: UnitGD
var AppliedBy: AppliedByGD
var Deather: UnitGD

func setInfo(_Unit: UnitGD = null, _AppliedBy: AppliedByGD = null, _Deather: UnitGD = null) -> void:
	Unit = _Unit
	AppliedBy = _AppliedBy
	Deather = _Deather
