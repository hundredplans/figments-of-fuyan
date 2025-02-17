class_name RemoveFromDeckAction extends Action

var Card: CardGD
@export var destroy: bool

func _init(_Card: CardGD = null, _destroy: bool = false) -> void:
	super()
	Card = _Card
	destroy = _destroy
	
func onPostAction() -> void:
	Card.onChangeCardPlace(Game.CardPlaces.NULL)
	if destroy: Card.onClear()
