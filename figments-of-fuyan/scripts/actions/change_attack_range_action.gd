class_name ChangeAttackRangeAction extends Action

var Card: CardGD
var attack_range: int

func _init(_Card: CardGD = null, _attack_range: int = 0) -> void:
	super()
	Card = _Card
	attack_range = _attack_range
	
func onPreAction() -> void:
	if Card == null: onFailAction()
	
func onPostAction() -> void:
	Card.setAttackRange(attack_range)
