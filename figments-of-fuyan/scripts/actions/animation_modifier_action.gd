class_name AnimationModifierAction extends Action

var Card: CardGD
var animation_name: String
var modifier: String

func _init(_Card: CardGD = null, _animation_name: String = "", _modifier: String = "") -> void:
	super()
	Card = _Card
	animation_name = _animation_name
	modifier = _modifier
	
func onPreAction() -> void:
	pass
	
func onPostAction() -> void:
	Card.setAnimationModifier(animation_name, modifier)
