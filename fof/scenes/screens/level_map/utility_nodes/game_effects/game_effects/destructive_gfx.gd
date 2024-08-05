extends GameFXGD

var Trait: TraitGD
var status_fx: StatusFXGD
func onCreateGFX() -> void:
	custom_triggers = [
		TriggerGD.new(self, Unit, onRemove, TriggerGD.REMOVE, TriggerGD.NULL)
	]
	status_fx = StatusManager.onCreateStatusFX(Unit, StatusFXInfoGD.IDS.DESTRUCTIVE, AppliedByGD.new(AppliedByGD.TRINKET, Trait))
	
func onRemove() -> void:
	StatusManager.onRemoveStatusFX(status_fx)
