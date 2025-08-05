class_name RemoveActiveEffectAction extends Action

var Fof: FofGD
var active_effect: ActiveEffectDatastore

func _init(_Fof: FofGD = null, _active_effect: ActiveEffectDatastore = null) -> void:
	super()
	Fof = _Fof
	active_effect = _active_effect
	
func onPreAction() -> void:
	pass
	
func onPostAction() -> void:
	Fof.onRemoveActiveEffect(active_effect)
