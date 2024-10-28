class_name AddToolAction extends Action

var Card: CardGD
var Tool: ToolGD

func _init(_Card: CardGD = null, _Tool: ToolGD = null) -> void:
	super()
	Card = _Card
	Tool = _Tool
	
func onPreAction() -> void:
	if Card.Tool != null: force_action.emit(RemoveToolAction.new(Card))
	
func onPostAction() -> void:
	Card.onAddTool(Tool)

func getDelay() -> float:
	return super()
