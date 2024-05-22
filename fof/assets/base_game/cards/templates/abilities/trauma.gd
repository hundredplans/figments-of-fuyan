class_name TraumaGD
extends AbilityGD

const type: String = "Trauma"
var Unit: UnitGD
var Deather: UnitGD
var AppliedBy: AppliedByGD

func setInfo(_Unit: UnitGD = null, _Deather: UnitGD = null, _AppliedBy: AppliedByGD = null):
	Unit = _Unit
	Deather = _Deather
	AppliedBy = _AppliedBy
