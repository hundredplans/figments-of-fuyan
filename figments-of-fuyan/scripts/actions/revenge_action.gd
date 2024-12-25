class_name RevengeAction extends Action

var Card: CardGD
var action: DamageAction
var fail_on_zero_health: bool = false

func _init(_Card: CardGD = null, _action: DamageAction = null, _fail_on_zero_health: bool = false) -> void:
	super()
	Card = _Card
	action = _action
	fail_on_zero_health = _fail_on_zero_health
	
func onPreAction() -> void:
	onCheckFail()
	
func onCheckFail() -> void:
	if fail_on_zero_health and Card.health == 0: onFailAction()
	
func onPostAction() -> void:
	Card.onRevenge(action)
