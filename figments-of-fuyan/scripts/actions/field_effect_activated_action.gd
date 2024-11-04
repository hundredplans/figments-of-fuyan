class_name FieldEffectActivatedAction extends Action

var FieldEffect: FieldEffectGD
var action: Action

func _init(_FieldEffect: FieldEffectGD = null, _action: Action = null) -> void:
	super()
	FieldEffect = _FieldEffect
	action = _action
	
func onPreAction() -> void:
	pass
	
func onPostAction() -> void:
	FieldEffect.onFieldEffect(action)

func getDelay() -> float:
	return super()
