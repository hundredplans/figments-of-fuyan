class_name AddToToolbeltAction extends Action

const TOOLBELT_SIZE: int = 2
var Tool: ToolGD
func _init(_Tool: ToolGD = null) -> void:
	super()
	Tool = _Tool
	
func onPreAction() -> void:
	if Game.getSaveFile().getToolbelt().size() > TOOLBELT_SIZE: onFailAction()
	
func onPostAction() -> void:
	Tool.reparent(Game.getSaveFile())
	Game.getSaveFile().getToolbelt().append(Tool)
