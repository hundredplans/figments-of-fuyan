class_name AddToolAction extends Action

var Card: CardGD
var Tool: ToolGD
var ignore: bool
var keep_tool: bool

func _init(_Card: CardGD = null, _Tool: ToolGD = null, _keep_tool: bool = false) -> void:
	super()
	Card = _Card
	Tool = _Tool
	keep_tool = _keep_tool
	
func onPreAction() -> void:
	if Card.Tool != null:
		if Card.Tool.info.id != Tool.info.id or Card.Tool.getTier() < Tool.getTier():
			onForceAction(RemoveToolAction.new(Card))
		elif Card.Tool.getTier() == Tool.getTier() and Tool.getTier() != Game.MAX_TOOL_TIER:
			if !keep_tool:
				Tool.onClear()
			onForceAction(ToolRetieredAction.new(Card.Tool, Card.Tool.getTier() + 1))
			onFailAction()
		else:
			if !keep_tool:
				Tool.onClear()
			onFailAction()
	
func onPostAction() -> void:
	Tool.reparent(Card)
	Card.onAddTool(Tool)
	Tool.Card = Card
	Tool.onToolEquipped()
