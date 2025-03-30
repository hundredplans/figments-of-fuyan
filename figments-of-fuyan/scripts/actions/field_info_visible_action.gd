class_name FieldInfoVisibleAction extends Action

var Card: CardGD
var state: bool

func _init(_Card: CardGD = null, _state: bool = false) -> void:
	super()
	Card = _Card
	state = _state
	
func onPreAction() -> void:
	pass
	
func onPostAction() -> void:
	Card.setFieldInfoVisible(state)
