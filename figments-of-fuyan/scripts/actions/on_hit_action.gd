class_name OnHitAction extends Action

var Card: CardGD
var damage_action: DamageAction
var attack_action: AttackAction


func _init(_Card: CardGD = null, action: DamageAction = null) -> void:
	Card = _Card
	damage_action = action
	attack_action = action.owner
	
func onPostAction() -> void:
	Card.onHit(damage_action, attack_action)
