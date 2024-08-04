extends GameFXGD

var status_fx: StatusFXGD
func onCreateGFX() -> void:
	Unit.VISION_RANGE = 1
	custom_triggers = [
		TriggerGD.new(self, Unit, onRemove, TriggerGD.REMOVE, TriggerGD.NULL)
	]
	VFX.onCreateUnitVFX(Unit, "Blind")
	status_fx = StatusManager.onCreateStatusFX(Unit, StatusFXInfoGD.IDS.BLIND)
	Vision.onRecalculateVision(Unit)
	
func onRemove() -> void:
	Unit.VISION_RANGE = 5
	VFX.onRemoveUnitVFX(Unit, "Blind")
	StatusManager.onRemoveStatusFX(status_fx)
	Vision.onRecalculateVision(Unit)
