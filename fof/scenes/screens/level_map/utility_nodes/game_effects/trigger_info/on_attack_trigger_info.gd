class_name OnAttackTriggerInfoGD
extends TriggerInfoGD

# Unit that is defending
var Unit: UnitGD

func _init(_Unit: UnitGD = null) -> void:
	Unit = _Unit
