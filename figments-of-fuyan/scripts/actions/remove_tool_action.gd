class_name RemoveToolAction extends Action

var Card: CardGD
var keep_tool: bool # Doesn't onClear the tool

func _init(_Card: CardGD = null, _keep_tool: bool = false) -> void:
	super()
	Card = _Card
	keep_tool = _keep_tool
	
func onPreAction() -> void:
	if Card.getTool() == null: onFailAction()
	
func onPostAction() -> void:
	var Tool: ToolGD = Card.getTool()
	Card.onRemoveTool()
	Tool.onToolUnequippedDefault(keep_tool)
