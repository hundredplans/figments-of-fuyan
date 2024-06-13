class_name SafetyInfoGD
extends Resource

var Unit: UnitGD
var safety: int

func _init(_Unit: UnitGD = null, _safety: int = 0) -> void:
	Unit = _Unit
	safety = _safety
