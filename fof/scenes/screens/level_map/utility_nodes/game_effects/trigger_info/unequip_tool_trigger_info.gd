class_name UnequipToolTriggerInfoGD
extends TriggerInfoGD

var Tool: ToolGD
var OldTool: ToolGD

func _init(_OldTool: ToolGD = null, _Tool: ToolGD = null) -> void:
	OldTool = _OldTool 
	Tool = _Tool
