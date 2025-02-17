class_name RemoveToolAction extends Action

var Card: CardGD

func _init(_Card: CardGD = null) -> void:
	super()
	Card = _Card
	
func onPreAction() -> void:
	if Card.getTool() == null: onFailAction()
	
func onPostAction() -> void:
	var Tool: ToolGD = Card.getTool()
	Card.onRemoveTool()
	Tool.onToolUnequipped()
