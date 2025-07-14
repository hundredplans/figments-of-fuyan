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
		if Card.Tool.info.id != Tool.info.id:
			onForceAction(RemoveToolAction.new(Card))
		elif !Card.Tool.getAscended():
			if !keep_tool:
				Tool.onClear()
			onForceAction(AscendToolAction.new(Card.Tool))
			onFailAction()
		else: onFailAction()
	
func onPostAction() -> void:
	Tool.reparent(Card)
	Card.onAddTool(Tool)
	Tool.Card = Card
	Tool.onToolEquipped()
