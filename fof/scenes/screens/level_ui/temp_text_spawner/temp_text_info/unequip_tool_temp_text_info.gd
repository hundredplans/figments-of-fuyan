class_name UnequipToolTempTextInfoGD
extends TempTextInfoGD

var Tool: ToolGD
func _init(_tool: ToolGD = null) -> void:
	Tool = _tool

func getText() -> String:
	if Tool.is_ascended:
		return "You unequipped: [wave amp=50.0 freq=5.0 connected=1][color=yellow]" + Tool.tool_info.display_name + "[/color][/wave]"
	return "You unequipped: " + Tool.tool_info.display_name
