class_name WhenHealedAction extends Action

var Card: CardGD
var action: StatAction

func _init(_Card: CardGD = null, _action: StatAction = null) -> void:
	super()
	Card = _Card
	action = _action
	
func onPreAction() -> void:
	pass
	
func onPostAction() -> void:
	Card.onWhenHealed(action)
