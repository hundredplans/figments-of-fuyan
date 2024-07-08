extends GameFXGD

var heal_info: HealInfoGD
var heal_info_array: HealInfoArrayGD

func onCreateGFX() -> void:
	heal_info_array = HealInfoArrayGD.new(Unit, heal_info.heal, [heal_info])
	custom_triggers = [
		TriggerGD.new(self, Unit, onRemove, TriggerGD.NEXT_TURN, TriggerGD.REMOVE_FX)
	]
	StatusManager.onCreateHealNextTurn(heal_info_array)

func onCombine(a: Dictionary) -> bool:
	heal_info_array.onCombine(a.heal_info)
	StatusManager.onCreateHealNextTurn(heal_info_array)
	return true

func onRemove() -> void:
	for heal_info in heal_info_array.array: Combat.onHeal(heal_info)
	StatusManager.onRemoveHealNextTurn(heal_info_array)
	
	
