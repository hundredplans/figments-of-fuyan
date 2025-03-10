class_name ChangeToolChargesAction extends Action

var Tool: ToolGD
var delta: int

func _init(_Tool: ToolGD = null, _delta: int = 0) -> void:
	super()
	Tool = _Tool
	delta = _delta
	
func onPreAction() -> void:
	if delta == 0 or !Tool.info.use_charges:
		onFailAction()
	
func onPostAction() -> void:
	Tool.onChangeCharges(delta)
