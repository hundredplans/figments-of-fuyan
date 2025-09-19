class_name AddStatusEffectAction extends Action

var StatusEffect: StatusEffectGD

func _init(_StatusEffect: StatusEffectGD = null) -> void:
	super()
	StatusEffect = _StatusEffect

func onPreAction() -> void:
	if StatusEffect.Card is EpicCardGD:
		StatusEffect.onClear()
		onFailAction()
		return
	
	var OtherStatusEffect: StatusEffectGD = StatusEffect.Card.getStatusEffect(StatusEffect.info.id)
	if OtherStatusEffect != null:
		if (OtherStatusEffect.turns < StatusEffect.turns) and OtherStatusEffect.turns != -1:
			onPushAction(RemoveStatusEffectAction.new(OtherStatusEffect))
		else: StatusEffect.onClear(); onFailAction()

func onPostAction() -> void:
	StatusEffect.Card.onAddStatusEffect(StatusEffect)
	StatusEffect.onStatusEffectAdded(self)

func getLogInfo() -> Array:
	return ["StatusEffect: " + StatusEffect.info.name, "Turns: " + str(StatusEffect.turns)]

func getGameEffect() -> GameEffectGD: return StatusEffect
func getCard() -> CardGD: return StatusEffect.Card
