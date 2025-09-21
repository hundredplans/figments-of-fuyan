class_name InsertAction extends Action

var Card: CardGD

func _init(_Card: CardGD) -> void:
	super()
	Card = _Card

func onPostAction() -> void:
	Card.add_to_group("AllyCardsGD")
	onPushAction(HandCardAction.new(Card))
