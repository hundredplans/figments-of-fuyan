class_name WhenStruckTriggerInfoGD
extends TriggerInfoGD

var Attacker: UnitGD
var AppliedBy: AppliedByGD

func _init(_Attacker: UnitGD = null, _AppliedBy: AppliedByGD = null) -> void:
	Attacker = _Attacker
	AppliedBy = _AppliedBy
