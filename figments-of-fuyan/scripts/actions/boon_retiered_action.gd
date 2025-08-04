class_name BoonRetieredAction extends Action

var Boon: BoonGD
var tier: int

func _init(_Boon: BoonGD = null, _tier: int = 1) -> void:
	Boon = _Boon
	tier = _tier
	
func onPreAction() -> void: pass

func onPostAction() -> void:
	Boon.onRetiered(tier)
