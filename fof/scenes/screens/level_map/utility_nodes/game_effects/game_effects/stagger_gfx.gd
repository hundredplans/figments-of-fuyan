extends GameFXGD

func onCreateGFX() -> void:
	custom_triggers = [
		TriggerGD.new(self, Unit, onRemove, TriggerGD.TURN_PASSED, TriggerGD.REMOVE_FX)
	]
	VFX.onCreateUnitVFX(Unit, "Stagger")
	StatusManager.onAddUnitFX(Unit, "Stagger")
	StatusManager.onUpdateUnitTargetAbilities(Unit)

func onRemove() -> void:
	VFX.onRemoveUnitVFX(Unit, "Stagger")
	StatusManager.onRemoveUnitFX(Unit, "Stagger")
