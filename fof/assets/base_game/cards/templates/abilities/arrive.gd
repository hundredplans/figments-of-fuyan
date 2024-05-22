class_name ArriveGD
extends AbilityGD

const type: String = "Arrive"
var Unit: UnitGD

func setInfo(_Unit: UnitGD = null) -> void:
	Unit = _Unit
