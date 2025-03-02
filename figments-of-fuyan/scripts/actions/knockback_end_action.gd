class_name KnockbackEndAction extends Action

var Card: CardGD
func _init(_Card: CardGD = null) -> void:
	Card = _Card

func onPreAction() -> void:
	pass
	
func onPostAction() -> void:
	Card.setIsKnockback(false)
