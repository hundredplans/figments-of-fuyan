class_name BuffInfoArrayGD
extends Resource
# Meant to use for a BuffInfo of the same stat where we add all the values, can't be used for absolutes
# Interact with this via Combat
var Unit: UnitGD
@export var value: int = 1
@export var stat: String
@export var array: Array # List of BuffInfo's and their respective values

func _init(_Unit: UnitGD = null, _stat: String = "attack", _value: int = 1, _array: Array = []) -> void:
	Unit = _Unit
	stat = _stat
	value = _value
	array = _array
	
func onCombine(buff_info: BuffInfoGD) -> void:
	array.append(buff_info)
	value += buff_info.value
