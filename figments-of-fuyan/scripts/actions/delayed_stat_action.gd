class_name DelayedStatAction extends Action

var turn_delay: int
var stat_action: StatAction

func _init(_turn_delay: int = 0, _stat_action: StatAction = null) -> void:
	super()
	turn_delay = _turn_delay
	stat_action = _stat_action
	
func onPreAction() -> void:
	stat_action.setTurnDelay(turn_delay)
	stat_action.owner = owner
	
func onPostAction() -> void:
	stat_action.GameObject.onAddDelayedStatAction(stat_action)
