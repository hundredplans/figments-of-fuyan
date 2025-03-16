class_name AddStatusEffectAction extends Action

var StatusEffect: StatusEffectGD

func _init(_StatusEffect: StatusEffectGD = null) -> void:
	super()
	StatusEffect = _StatusEffect

func onPreAction() -> void:
	if StatusEffect.Card is EpicCardGD:
		StatusEffect.onClear()
		onFailAction()

func onPostAction() -> void:
	StatusEffect.Card.onAddStatusEffect(StatusEffect)
	StatusEffect.onStatusEffectAdded(self)

func getLogInfo() -> Array:
	return ["StatusEffect: " + StatusEffect.info.name, "Turns: " + str(StatusEffect.turns)]
