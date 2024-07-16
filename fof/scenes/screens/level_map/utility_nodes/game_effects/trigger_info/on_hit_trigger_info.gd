class_name OnHitTriggerInfoGD
extends TriggerInfoGD

var Defender: UnitGD
var AppliedBy: AppliedByGD

func _init(_Defender: UnitGD = null, _AppliedBy: AppliedByGD = null) -> void:
	Defender = _Defender
	AppliedBy = _AppliedBy
