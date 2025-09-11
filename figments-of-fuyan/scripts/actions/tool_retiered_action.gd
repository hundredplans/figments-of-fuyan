class_name ToolRetieredAction extends Action

var Tool: ToolGD
var tier: int

func _init(_Tool: ToolGD = null, _tier: int = 1) -> void:
	super()
	Tool = _Tool
	tier = _tier
	
func onPreAction() -> void: pass

func onPostAction() -> void:
	Tool.onRetiered(tier)
