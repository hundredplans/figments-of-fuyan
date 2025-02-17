class_name AddToolAction extends Action

var Card: CardGD
var Tool: ToolGD
var ignore: bool

func _init(_Card: CardGD = null, _Tool: ToolGD = null, _ignore: bool = false) -> void:
	super()
	Card = _Card
	Tool = _Tool
	ignore = _ignore
	
func onPreAction() -> void:
	if Card.Tool != null:
		if Card.Tool.info.id != Tool.info.id:
			onForceAction(RemoveToolAction.new(Card))
		elif !Card.Tool.getAscended() and !ignore:
			onForceAction(AscendToolAction.new(Card.Tool))
			onFailAction()
	
func onPostAction() -> void:
	Tool.reparent(Card)
	Card.onAddTool(Tool)
	Tool.Card = Card
	Tool.onToolEquipped()
