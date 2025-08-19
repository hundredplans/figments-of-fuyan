class_name BoonDisabledAction extends Action

var Boon: BoonGD
var disabled: bool

func _init(_Boon: BoonGD = null, _disabled: bool = false) -> void:
	super()
	Boon = _Boon
	disabled = _disabled
	
func onPreAction() -> void:
	pass
	
func onPostAction() -> void:
	Boon.setDisabled(disabled)
