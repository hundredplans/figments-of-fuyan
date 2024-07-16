class_name ToolsGD
extends Node

var StatusManager: StatusManagerGD
var all_tools: Array
func _ready() -> void:
	const DIR_PATH: String = "res://assets/base_game/tools/infos/"
	all_tools = Array(DirAccess.get_files_at(DIR_PATH)).map(func(x: String): return load(DIR_PATH + x))

# Obj is game_card or Unit
func onEquipTool(Obj: Variant, id: int, is_ascended: bool = false) -> void:
	var tool_info: ToolInfoGD = onFindToolInfo(id)
	var tool := Node.new()
	tool.script = tool_info.tool_script
	tool.setInfo(tool_info, is_ascended)
	add_child(tool)
	Obj.onEquipTool(tool)
	
	if Obj is UnitGD:
		StatusManager.onEquipTool(Obj)

func onFindToolInfo(id: int) -> ToolInfoGD:
	return all_tools.filter(func(x: ToolInfoGD): return x.id == id)[0]
	
func onTrigger(Unit: UnitGD, trigger: int, args: TriggerInfoGD) -> void:
	for tool in get_children().filter(func(x: ToolGD): return x.has_method("onTrigger")):
		tool.onTrigger(Unit, trigger, args)
		
func onHandPhaseStart() -> void:
	for tool in get_children(): tool.onStartTurnTrigger(0)
	
func onAIPhaseStart() -> void:
	for tool in get_children(): tool.onStartTurnTrigger(1)
