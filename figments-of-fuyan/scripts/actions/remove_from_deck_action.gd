class_name RemoveFromDeckAction extends Action

var Card: CardGD

func _init(_Card: CardGD = null) -> void:
	super()
	Card = _Card
	
func onPostAction() -> void:
	Game.getSaveFile().onRemoveCard(Card)
