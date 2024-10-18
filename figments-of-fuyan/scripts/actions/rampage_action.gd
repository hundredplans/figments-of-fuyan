class_name RampageAction extends Action

var Card: CardGD
var death_action: DeathAction

func _init(_Card: CardGD = null, _death_action: DeathAction = null) -> void:
	Card = _Card
	death_action = _death_action
	
func onPostAction() -> void:
	Card.onRampage(death_action)
