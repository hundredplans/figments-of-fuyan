class_name InVisionResetAction extends Action

var Card: CardGD
var in_vision_cards: Array

func _init(_Card: CardGD = null, _in_vision_cards: Array = []) -> void:
	super()
	Card = _Card
	in_vision_cards = _in_vision_cards
	
func onPreAction() -> void:
	if in_vision_cards.is_empty():
		in_vision_cards = Game.inVisionCards(Card)
	
func onPostAction() -> void:
	var actions: Array = in_vision_cards.map(func(x: CardGD): return VisionAction.new(x))
	onPushAction(actions)
		
