class_name ChangeActiveEffectChargesAction extends Action

var active_effect: ActiveEffectDatastore
var delta: int
var set_to_infinite: bool

func _init(_active_effect: ActiveEffectDatastore = null, _delta: int = 0, _set_to_infinite: bool = false) -> void:
	super()
	active_effect = _active_effect
	delta = _delta
	set_to_infinite = _set_to_infinite
	
func onPreAction() -> void:
	pass
	
func onPostAction() -> void:
	if set_to_infinite:
		active_effect.charges = -1
		
	elif active_effect.charges != -1:
		active_effect.charges += delta
		
	if active_effect.charges == 0 and active_effect.owner is ToolGD and active_effect.owner.getRarity() == Game.Rarities.MINI:
		onPushAction(RemoveToolAction.new(active_effect.owner.Card))

func getDelay() -> float:
	return super()

func getLogInfo() -> Array:
	return ["ActiveEffect: " + active_effect.name, "Charges: " + str(active_effect.charges), "Delta: " + str(delta)]
