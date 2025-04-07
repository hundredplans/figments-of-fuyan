class_name RemoveStatusEffectAction extends Action

var StatusEffect: StatusEffectGD
func _init(_StatusEfffect: StatusEffectGD = null) -> void:
	super()
	StatusEffect = _StatusEfffect

func onPreAction() -> void:
	if StatusEffect == null: onFailAction()

func onPostAction() -> void:
	StatusEffect.onClear()

func getLogInfo() -> Array:
	return ["StatusEffect: " + StatusEffect.info.name if StatusEffect != null else ""]
