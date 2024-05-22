class_name LastWillGD
extends AbilityGD

const type: String = "LastWill"
var Deather: UnitGD
var AppliedBy: AppliedByGD

func setInfo(_Deather: UnitGD = null, _AppliedBy: AppliedByGD = null) -> void:
	Deather = _Deather
	AppliedBy = _AppliedBy
