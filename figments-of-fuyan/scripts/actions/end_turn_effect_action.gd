class_name EndTurnEffectAction extends Action

var Card: CardGD
var action: ChangeTurnStateAction

func _init(_Card: CardGD = null, _action: ChangeTurnStateAction = null) -> void:
	super()
	Card = _Card
	action = _action
	
func onPreAction() -> void:
	pass
	
func onPostAction() -> void:
	Card.onEndTurnEffect(action)
