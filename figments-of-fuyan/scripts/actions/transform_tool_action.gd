class_name TransformToolAction extends Action

var NewTool: ToolGD
var Tool: ToolGD
var all: Array

func _init(_Tool: ToolGD = null) -> void:
	super()
	Tool = _Tool
	
func onPreAction() -> void:
	pass
	
func onPostAction() -> void:
	var all: Array = Helper.getFofInfoArray(ToolInfo)
	all = all.filter(func(x: FofInfo): return x != Tool.info and x.rarity == Tool.getRarity())
	if all.is_empty(): return
	
	var tool_info: ToolInfo = all.pick_random()
	var tool_data: SavedDataTool = tool_info.saved_data.new(tool_info.id, true)
	NewTool = SavedData.onLoadModel(tool_data, Game.getSaveFile())
	
	var remove_tool_action := RemoveToolAction.new(Tool.getCard())
	var add_tool_action := AddToolAction.new(Tool.getCard(), NewTool)
	if !forced: onPushAction([remove_tool_action, add_tool_action])
	else: onForceAction(remove_tool_action); onForceAction(add_tool_action)

func getNewTool() -> ToolGD:
	return NewTool
