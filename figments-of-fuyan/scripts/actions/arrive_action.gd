class_name ArriveAction extends Action

var Card: CardGD
var action: AwakenAction

func _init(_Card: CardGD = null, _action: AwakenAction = null) -> void:
	super()
	Card = _Card
	action = _action
	
func onPreAction() -> void:
	pass
	
func onPostAction() -> void:
	Card.onArrive(action)

func getDelay() -> float:
	return super()
