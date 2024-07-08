extends GameFXGD

var TargetUnit: UnitGD
func onCreateGFX() -> void:
	custom_triggers = [
		TriggerGD.new(self, TargetUnit, StatusManager.onRemoveUnitFX.bind(Unit, "CharmingStance"), TriggerGD.REMOVE_ABILITY, TriggerGD.REMOVE_FX)
	]
	StatusManager.onAddUnitFX(Unit, "CharmingStance", AppliedByGD.new("Ability", TargetUnit))
