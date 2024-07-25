class_name AuraGD
extends AbilityGD

const type = "Aura"
var TriggerUnit: UnitGD
var AuraUnit: UnitGD

var callable: Callable

# Units that have already been triggered
var affected_units: Array

func setInfo(_Unit: UnitGD = null) -> void:
	AuraUnit = _Unit

func onFindStatusFXS(_Unit: UnitGD, status_fxs: Array[StatusFXGD]) -> StatusFXGD:
	if !_Unit.is_dead:
		for status_fx in status_fxs:
			if status_fx.Unit == _Unit:
				return status_fx
	return null
