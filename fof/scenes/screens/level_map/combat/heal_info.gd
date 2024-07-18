class_name HealInfoGD
extends Resource

var Healee: UnitGD
var heal: int
var AppliedBy: AppliedByGD

func _init(_Healee: UnitGD, _heal: int = 0, _AppliedBy: AppliedByGD = null) -> void:
	Healee = _Healee
	heal = _heal
	AppliedBy = _AppliedBy
