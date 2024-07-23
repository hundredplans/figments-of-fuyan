extends GameFXGD

func onCreateGFX() -> void:
	custom_triggers = [
		TriggerGD.new(self, Unit, Units.changeStats.bind(StatInfoGD.new(Unit, AppliedByGD.new(), StatsGD.BOTH_HEALTH, 1)), TriggerGD.RAMPAGE, TriggerGD.NULL)
	]
	StatusManager.onCreateStatusFX(Unit, StatusFXInfoGD.IDS.HELPFUL_HELMET)
	if Unit.team == 0: SpectateCamera.onSpectate(Unit)
	VFX.onCreateUnitVFX(Unit, "HelpfulHelmet")
