class_name ChangeToolChargesAction extends Action

var Tool: ToolGD
var delta: int
var infinite: bool

func _init(_Tool: ToolGD = null, _delta: int = 0, _infinite: bool = false) -> void:
	super()
	Tool = _Tool
	delta = _delta
	infinite = _infinite
	
func onPreAction() -> void:
	if delta == 0 or !Tool.info.use_charges:
		onFailAction()
	
func onPostAction() -> void:
	Tool.onChangeCharges(delta, infinite)
