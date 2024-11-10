class_name KnockbackAction extends Action

var Card: CardGD
var Applier: GameObjectGD
var knockback: int
var direction: int

func _init(_Card: CardGD = null, _Applier: GameObjectGD = null, _knockback: int = 0, _direction: int = 0) -> void:
	super()
	Card = _Card
	Applier = _Applier
	knockback = _knockback
	direction = _direction
	
func onPreAction() -> void:
	pass
	
func onPostAction() -> void:
	pass

func getDelay() -> float:
	return super()
