class_name MovementFinishAction extends Action

var Card: CardGD

func _init(_Card: CardGD = null) -> void:
	Card = _Card
	
func onPostAction() -> void:
	Card.onIdle()
