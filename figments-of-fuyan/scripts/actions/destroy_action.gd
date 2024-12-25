class_name DestroyAction extends Action

var Card: CardGD
var Destroyer: FofGD

func _init(_Card: CardGD = null, _Destroyer: FofGD = null) -> void:
	super()
	Card = _Card
	Destroyer = _Destroyer
	
func onPreAction() -> void:
	pass
	
func onPostAction() -> void:
	onPushAction(DeathAction.new(Destroyer, Card, Card.health, Card.health))
