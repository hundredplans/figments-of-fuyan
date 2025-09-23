class_name HandCardAction extends Action # Used to insert / add to your hand

var Card: CardGD
func _init(_Card: CardGD = null) -> void:
	super()
	Card = _Card
