extends GameFXGD

var status_fx: StatusFXGD
var TargetUnit: UnitGD
func onCreateGFX() -> void:
	status_fx = StatusManager.onCreateStatusFX(Unit, StatusFXInfoGD.IDS.CHARMING_STANCE, AppliedByGD.new(AppliedByGD.ABILITY, TargetUnit), Unit)
	custom_triggers = [
		TriggerGD.new(self, TargetUnit, StatusManager.onRemoveStatusFX.bind(status_fx), TriggerGD.REMOVE_ABILITY, TriggerGD.REMOVE_FX)
	]

