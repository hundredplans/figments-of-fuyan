extends GameFXGD

var status_fx: StatusFXGD
func onCreateGFX() -> void:
	custom_triggers = [
		TriggerGD.new(self, Unit, onRemove, TriggerGD.TURN_PASSED, TriggerGD.REMOVE_FX)
	]
	VFX.onCreateUnitVFX(Unit, "Daze")
	status_fx = StatusManager.onCreateStatusFX(Unit, StatusFXInfoGD.IDS.DAZE)
	
	ActionManager.onRemoveActions([ActionManager.MOVE_UNIT])
	PlayerManager.onRefreshMovementRange(Unit)
	
func onRemove() -> void:
	VFX.onRemoveUnitVFX(Unit, "Daze")
	StatusManager.onRemoveStatusFX(status_fx)
