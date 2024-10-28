class_name RemoveToolAction extends Action

var Card: CardGD

func _init(_Card: CardGD = null) -> void:
	super()
	Card = _Card
	
func onPostAction() -> void:
	Card.onRemoveTool()
