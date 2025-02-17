class_name RemoveFromToolbeltAction extends Action

var Tool: ToolGD
var destroy: bool

func _init(_Tool: ToolGD = null, _destroy: bool = false) -> void:
	super()
	Tool = _Tool
	destroy = _destroy
	
func onPreAction() -> void:
	if Tool not in Game.getSaveFile().getToolbelt(): onFailAction()
	
func onPostAction() -> void:
	Game.getSaveFile().getToolbelt().erase(Tool)
	Tool.get_parent().remove_child(Tool)
	
	if destroy:
		Tool.onClear()
