class_name TraumaAction extends Action

var Card: CardGD
var death_action: DeathAction

func _init(_Card: CardGD = null, _death_action: DeathAction = null) -> void:
	super()
	Card = _Card
	death_action = _death_action
	
func onPostAction() -> void:
	Card.onTrauma(death_action)
	
