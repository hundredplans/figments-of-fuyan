class_name ToolActivatedAction extends Action

var Tool: ToolGD
var action: Action

func _init(_Tool: ToolGD = null, _action: Action = null):
	super()
	Tool = _Tool
	action = _action
	
func onPreAction():
	pass
	
func onPostAction():
	Tool.onToolAction(action)

func getLogInfo() -> Array:
	return ["Tool: " + Tool.info.name]
