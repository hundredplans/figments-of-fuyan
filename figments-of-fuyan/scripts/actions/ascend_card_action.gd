class_name AscendCardAction extends Action

var Card: CardGD
@export var state: bool

func _init(_Card: CardGD = null, _state: bool = true) -> void:
	super()
	Card = _Card
	state = _state
	
func onPreAction() -> void:
	pass
	
func onPostAction() -> void:
	Card.onAscend(state)
