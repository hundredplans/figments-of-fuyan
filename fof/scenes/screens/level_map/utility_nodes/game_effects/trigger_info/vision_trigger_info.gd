class_name VisionTriggerInfoGD
extends TriggerInfoGD

# This is always the other unit called
var Unit: UnitGD

func _init(_Unit: UnitGD = null) -> void:
	Unit = _Unit
