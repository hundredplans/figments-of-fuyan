class_name HealInfoGD
extends Resource

var Healee: UnitGD
@export var heal: int
@export var AppliedBy: AppliedByGD

func _init(_Healee: UnitGD = null, _AppliedBy: AppliedByGD = null, _heal: int = 1) -> void:
	Healee = _Healee
	heal = _heal
	AppliedBy = _AppliedBy
