class_name ChangeBoonChargesAction extends Action

var Boon: BoonGD
var delta: int

func _init(_Boon: BoonGD = null, _delta: int = 0) -> void:
	super()
	Boon = _Boon
	delta = _delta
	
func onPreAction() -> void:
	if delta == 0 or !Boon.info.use_charges:
		onFailAction()
	
func onPostAction() -> void:
	Boon.onChangeCharges(delta)
