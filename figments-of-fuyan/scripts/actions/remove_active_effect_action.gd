class_name RemoveActiveEffectAction extends Action

var Card: CardGD
var active_effect: ActiveEffectDatastore

func _init(_Card: CardGD = null, _active_effect: ActiveEffectDatastore = null) -> void:
	super()
	Card = _Card
	active_effect = _active_effect
	
func onPreAction() -> void:
	pass
	
func onPostAction() -> void:
	Card.onRemoveActiveEffect(active_effect)
