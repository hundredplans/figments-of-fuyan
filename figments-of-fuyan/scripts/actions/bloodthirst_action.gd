class_name BloodthirstAction extends Action

var Card: CardGD
var action: Action

func _init(_Card: CardGD = null, _action: DeathAction = null) -> void:
	super()
	Card = _Card
	action = _action
	
func onPreAction() -> void:
	pass
	
func onPostAction() -> void:
	Card.onBloodthirst(action)

func getDelay() -> float:
	return super()
