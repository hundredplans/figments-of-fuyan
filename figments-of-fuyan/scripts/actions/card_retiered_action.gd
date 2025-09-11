class_name CardRetieredAction extends Action

var Card: CardGD
@export var tier: int

func _init(_Card: CardGD = null, _tier: int = 1) -> void:
	super()
	Card = _Card
	tier = _tier
	
func onPreAction() -> void:
	pass
	
func onPostAction() -> void:
	if Card == null: return
	Card.onRetiered(tier)
	
func getTier() -> int: return tier
