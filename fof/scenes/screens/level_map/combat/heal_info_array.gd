class_name HealInfoArrayGD

var Healee: UnitGD
@export var heal: int
var array: Array # Array of heals

func _init(_Healee: UnitGD = null, _heal: int = 1, _array: Array = []) -> void:
	Healee = _Healee
	heal = _heal
	array = _array

func onCombine(heal_info: HealInfoGD) -> void:
	array.append(heal_info)
	heal += heal_info.heal
