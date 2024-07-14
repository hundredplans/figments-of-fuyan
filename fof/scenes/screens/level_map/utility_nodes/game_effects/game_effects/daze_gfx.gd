extends GameFXGD

func onCreateGFX() -> void:
	custom_triggers = [
		TriggerGD.new(self, Unit, onRemove, TriggerGD.TURN_PASSED, TriggerGD.REMOVE_FX)
	]
	VFX.onCreateUnitVFX(Unit, "Daze")
	StatusManager.onAddUnitFX(Unit, "Daze")
	PlayerManager.onRefreshMovementRange()
	
func onRemove() -> void:
	VFX.onRemoveUnitVFX(Unit, "Daze")
	StatusManager.onRemoveUnitFX(Unit, "Daze")
