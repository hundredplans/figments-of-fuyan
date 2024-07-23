class_name OngoingAbilityGD
extends AbilityGD

const type = "OngoingAbility"
var TriggerUnit: UnitGD
var Unit: UnitGD

var callable: Callable

# Units that have already been triggered
var affected_units: Array
# Units to apply the next trigger on
var trigger_info: Array

func setInfo(_Unit: UnitGD = null) -> void:
	Unit = _Unit
	
func onOngoingAbilityCondition(_Unit: UnitGD, _type: String, args: Array) -> bool:
	TriggerUnit = _Unit
	if has_method(_type): return callv(_type, args)
	return false

func onFindStatusFXS(_Unit: UnitGD, status_fxs: Array[StatusFXGD]) -> StatusFXGD:
	for status_fx in status_fxs:
		if status_fx.Unit == _Unit:
			return status_fx
	return null
