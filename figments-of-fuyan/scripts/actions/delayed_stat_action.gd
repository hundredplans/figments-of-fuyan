class_name DelayedStatAction extends Action

var stat_action: StatAction

func _init(_stat_action: StatAction = null) -> void:
	super()
	stat_action = _stat_action
	
func onPreAction() -> void:
	stat_action.owner = owner
	
func onPostAction() -> void:
	for stat_info in stat_action.stat_infos.filter(func(x: StatInfo): return x.turns > 0):
		stat_info.Card.onAddDelayedStatInfo(stat_info)
		stat_info.setOwner(stat_action.owner)
