class_name AppliedByGD
extends Resource

var type: String = "GameEvent"
var Applier: UnitGD

func _init(_type: String = "GameEvent", _Applier: UnitGD = null) -> void:
	Applier = _Applier
	type = _type
