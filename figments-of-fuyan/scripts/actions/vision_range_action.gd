class_name VisionRangeAction extends Action

var Card: CardGD
var delta: int

func _init(_Card: CardGD = null, _delta: int = 0) -> void:
	super()
	Card = _Card
	delta = _delta
	
func onPreAction() -> void:
	pass
	
func onPostAction() -> void:
	Card.onUpdateVisionRange(delta)
	onPushAction(VisionAction.new(Card, Card))
