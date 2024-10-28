class_name ChangeAttacksAction extends Action

var Card: CardGD
var attacks: int

func _init(_Card: CardGD = null, _attacks: int = 0) -> void:
	super()
	Card = _Card
	attacks = _attacks

func onPostAction() -> void:
	Card.setAttacks(attacks)

func getLogInfo() -> Array:
	return ["Card: " + Card.info.name, "Attacks: " + str(attacks)]
