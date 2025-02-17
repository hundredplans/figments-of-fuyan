class_name AscendToolAction extends Action

var Tool: ToolGD
@export var state: bool

func _init(_Tool: ToolGD = null, _state: bool = true) -> void:
	super()
	Tool = _Tool
	state = _state
	
func onPreAction() -> void:
	if Tool.getAscended(): onFailAction()
	
func onPostAction() -> void:
	Tool.setAscended(true)
