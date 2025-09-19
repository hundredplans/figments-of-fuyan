class_name RemoveFieldEffectAction extends Action

var FieldEffect: FieldEffectGD

func _init(_FieldEffect: FieldEffectGD = null) -> void:
	super()
	FieldEffect = _FieldEffect
	
func onPreAction() -> void:
	if FieldEffect == null: onFailAction()
	
func onPostAction() -> void:
	FieldEffect.onRemoveFromCard()

func getLogInfo() -> Array:
	return ["FieldEffect: " + FieldEffect.info.name if FieldEffect != null else ""]

func getCard() -> CardGD:
	if FieldEffect == null: return null
	return FieldEffect.Card
	
func getFieldEffectId() -> int:
	if FieldEffect == null: return -1
	return FieldEffect.info.id

func getGameEffect() -> GameEffectGD: return FieldEffect
