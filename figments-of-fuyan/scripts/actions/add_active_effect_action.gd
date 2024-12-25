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
	if active_effect is ActiveAbilityDatastore and (FofObject is CardGD or FofObject is ToolGD):
		if FofObject.ascended and active_effect.exists != Game.AscendedExists.ONLY_DEFAULT:
			active_effect.charges = active_effect.ascended_max_charges
		else: active_effect.charges = active_effect.max_charges
	elif active_effect is ActiveEffectDatastore:
		active_effect.charges = active_effect.max_charges	
	FofObject.onAddActiveEffect(active_effect)
	

func onCheckFail() -> void:
	if active_effect is ActiveAbilityDatastore and (FofObject is CardGD or FofObject is ToolGD):
		if FofObject.ascended and active_effect.exists == Game.AscendedExists.ONLY_DEFAULT: onFailAction()
		elif !FofObject.ascended and active_effect.exists == Game.AscendedExists.ONLY_ASCENDED: onFailAction()
