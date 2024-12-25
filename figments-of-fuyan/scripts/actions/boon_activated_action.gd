class_name BoonActivatedAction extends Action

var Boon: BoonGD
var action: Action

func _init(_Boon: BoonGD = null, _action: Action = null) -> void:
	super()
	Boon = _Boon
	action = _action
	
func onPreAction() -> void:
	pass
	
func onPostAction() -> void:
	Boon.onBoon(action)

func getLogInfo() -> Array:
	return ["Boon: " + Boon.info.name]
