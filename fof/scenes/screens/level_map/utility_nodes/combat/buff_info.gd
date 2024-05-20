class_name BuffInfoGD
extends Resource

var Unit: UnitGD
@export var value: int
@export var stat: String
@export var AppliedBy: AppliedByGD
@export var absolute: bool

func _init(_Unit: UnitGD = null, _AppliedBy: AppliedByGD = null, _stat: String = "attack", _value: int = 1, _absolute: bool = false) -> void:
	Unit = _Unit
	AppliedBy = _AppliedBy
	stat = _stat
	value = _value
	absolute = _absolute
