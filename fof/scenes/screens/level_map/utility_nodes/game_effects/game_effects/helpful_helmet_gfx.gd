extends GameFXGD

func onCreateGFX() -> void:
	custom_triggers = [
		TriggerGD.new(self, Unit, Unit.stats.bind("health", 1), TriggerGD.RAMPAGE, TriggerGD.NULL)
	]
	StatusManager.onAddUnitFX(Unit, "HelpfulHelmet")
	if Unit.team == 0: SpectateCamera.onSpectate(Unit)
	VFX.onCreateUnitVFX(Unit, "HelpfulHelmet")
