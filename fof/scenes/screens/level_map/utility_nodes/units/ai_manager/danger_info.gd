class_name DangerInfoGD
extends Resource

var Unit: UnitGD
var danger: int

func _init(_Unit: UnitGD = null, _danger: int = 0) -> void:
	Unit = _Unit
	danger = _danger
