class_name AddActiveEffectAction extends Action

var FofObject: FofGD
var active_effect: ActiveEffectDatastore

func _init(_FofObject: FofGD = null, _active_effect: ActiveEffectDatastore = null) -> void:
	super()
	FofObject = _FofObject
	active_effect = _active_effect
	
func onPreAction() -> void:
	onCheckFail()
	
func onPostAction() -> void:
	active_effect.owner = FofObject
	if active_effect is ActiveEffectDatastore:
		active_effect.charges = active_effect.max_charges
	FofObject.onAddActiveEffect(active_effect)
