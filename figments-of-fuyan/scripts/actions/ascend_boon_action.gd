class_name ChangeBoonAscenscionAction extends Action

var Boon: BoonGD
var is_ascend: bool = false

func _init(_Boon: BoonGD = null, _is_ascend: bool = false) -> void:
	super()
	Boon = _Boon
	is_ascend = _is_ascend
	
func onPreAction() -> void:
	if Boon.ascended == is_ascend: onFailAction()
	
func onPostAction() -> void:
	Boon.onAscend(true)

func getDelay() -> float:
	return super()
	
func getLogInfo() -> Array:
	return ["Boon: " + Boon.info.name]
