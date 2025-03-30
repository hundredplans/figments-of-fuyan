class_name IdleModifierAction extends Action

var Card: CardGD
var name: String

func _init(_Card: CardGD = null, _name: String = "") -> void:
	super()
	Card = _Card
	name = _name
	
func onPreAction() -> void:
	pass
	
func onPostAction() -> void:
	Card.setIdleModifier(name)
