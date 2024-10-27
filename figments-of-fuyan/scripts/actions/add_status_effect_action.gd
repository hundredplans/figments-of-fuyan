class_name AddStatusEffectAction extends Action

var StatusEffect: StatusEffectGD

func _init(_StatusEffect: StatusEffectGD = null) -> void:
	super()
	StatusEffect = _StatusEffect

func onPostAction() -> void:
	StatusEffect.Card.onAddStatusEffect(StatusEffect)

func getLogInfo() -> Array:
	return ["StatusEffect: " + StatusEffect.info.name, "Turns: " + str(StatusEffect.turns)]
