class_name ChangeActiveEffectUsedAction extends Action

var active_effect: ActiveEffectDatastore
var state: bool

func _init(_active_effect: ActiveEffectDatastore = null, _state: bool = false) -> void:
	super()
	active_effect = _active_effect
	state = _state
	
func onPreAction() -> void:
	if active_effect.used == state: onFailAction()
	
func onPostAction() -> void:
	active_effect.used = state

func getDelay() -> float:
	return super()

func getLogInfo() -> Array:
	return ["ActiveEffect: " + active_effect.name + "State: " + str(state)]
