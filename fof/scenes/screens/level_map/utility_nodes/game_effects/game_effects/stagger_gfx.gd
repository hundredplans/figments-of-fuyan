extends GameFXGD

var status_fx: StatusFXGD
func onCreateGFX() -> void:
	custom_triggers = [
		TriggerGD.new(self, Unit, onRemove, TriggerGD.TURN_PASSED, TriggerGD.REMOVE_FX)
	]
	VFX.onCreateUnitVFX(Unit, "Stagger")
	status_fx = StatusManager.onCreateStatusFX(Unit, StatusFXInfoGD.IDS.STAGGER)
	ActionManager.onRemoveActions([ActionManager.ATTACK])

func onRemove() -> void:
	VFX.onRemoveUnitVFX(Unit, "Stagger")
	StatusManager.onRemoveStatusFX(status_fx)
