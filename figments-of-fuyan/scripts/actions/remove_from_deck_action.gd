class_name RemoveFromDeckAction extends Action

var Card: CardGD
@export var destroy: bool

func _init(_Card: CardGD = null, _destroy: bool = false) -> void:
	super()
	Card = _Card
	destroy = _destroy
	
func onPostAction() -> void:
	if destroy:
		if Card.isAlive():
			var actions: Array = [DestroyAction.new(Card, null), RemoveFromDeckAction.new(Card, true)]
			onPushAction(actions)
			return
		else: Card.onClear()
	Card.onChangeCardPlace(Game.CardPlaces.NULL)
	
