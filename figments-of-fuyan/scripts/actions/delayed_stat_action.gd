class_name DelayedStatAction extends Action

var stat_infos: Array

func _init(_stat_infos: Variant = null) -> void:
	super()
	if _stat_infos is Array: stat_infos = _stat_infos
	elif _stat_infos is StatInfo: stat_infos = [_stat_infos]
	
func onPostAction() -> void:
	for stat_info in stat_infos.filter(func(x: StatInfo): return x.turns > 0):
		stat_info.Card.onAddDelayedStatInfo(stat_info)
		stat_info.setOwner(owner)

func getLogInfo() -> Array:
	var arr: Array = []
	for stat_info in stat_infos:
		arr.append("Card: " + stat_info.Card.info.name)
		arr.append("Stat: " + str(stat_info.types.map(Game.getStatString)))
		arr.append("Value: " + str(stat_info.values))
		arr.append("Absolute: " + str(stat_info.absolute))
		arr.append("Turns: " + str(stat_info.turns))
	return arr
