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
