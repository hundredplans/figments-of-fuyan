class_name AbilityTilesGD
extends Resource

var in_range: Array
var can_affect: Array

func onReset() -> void: in_range = []; can_affect = []
func setInfo(_in_range: Array = [], _can_affect: Array = []) -> void:
	in_range = _in_range
	can_affect = _can_affect
