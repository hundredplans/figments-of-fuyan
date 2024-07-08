extends GameFXGD

var stat: String
var buff_info: BuffInfoGD
var buff_info_array: BuffInfoArrayGD

func onCreateGFX() -> void:
	stat = buff_info.stat
	buff_info_array = BuffInfoArrayGD.new(Unit, stat, buff_info.value, [buff_info])
	custom_triggers = [
		TriggerGD.new(self, Unit, onRemove, TriggerGD.NEXT_TURN, TriggerGD.REMOVE_FX)
	]
	StatusManager.onCreateBuffNextTurn(buff_info_array)

func onCombine(a: Dictionary) -> bool:
	if a.stat != stat: return false
	buff_info_array.onCombine(a.buff_info)
	StatusManager.onCreateBuffNextTurn(buff_info_array)
	return true

func onRemove() -> void:
	for buff_info in buff_info_array.array: Combat.onBuffInfo(buff_info)
	StatusManager.onRemoveBuffNextTurn(buff_info_array)
