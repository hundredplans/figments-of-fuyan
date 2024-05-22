class_name WhenHealedGD
extends AbilityGD

const type: String = "WhenHealed"
var Unit: UnitGD
var heal_info: HealInfoGD
var heal: int

func setInfo(_Unit: UnitGD = null, _heal_info: HealInfoGD = null, _heal: int = 1) -> void:
	Unit = _Unit
	heal_info = _heal_info
	heal = _heal
