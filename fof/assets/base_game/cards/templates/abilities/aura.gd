class_name AuraGD
extends AbilityGD

const type = "Aura"
var TriggerUnit: UnitGD
var Unit: UnitGD

var callable: Callable

# Units that have already been triggered
var affected_units: Array
# Units to apply the next trigger on
var trigger_info: Array

func setInfo(_Unit: UnitGD = null) -> void:
	Unit = _Unit
	
func onAuraCondition(_Unit: UnitGD, _type: String, args: Array) -> bool:
	TriggerUnit = _Unit
	if has_method(_type): return callv(_type, args)
	return false
