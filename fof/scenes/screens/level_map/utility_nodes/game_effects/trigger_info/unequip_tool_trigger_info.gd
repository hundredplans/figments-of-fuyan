class_name UnequipToolTriggerInfoGD
extends TriggerInfoGD

var Tool: ToolGD
var NewTool: ToolGD

func _init(_NewTool: ToolGD = null, _Tool: ToolGD = null) -> void:
	NewTool = _NewTool
	Tool = _Tool
