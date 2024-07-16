extends GameFXGD

@export var IDLE_SPEEDUP_MULT: float = 2
var speed: int
func onCreateGFX() -> void:
	custom_triggers = [
		TriggerGD.new(self, Unit, onRemove, TriggerGD.NEXT_TURN, TriggerGD.REMOVE_FX)
	]
	var AppliedBy := AppliedByGD.new("EnergizedBoon")
	VFX.onCreateUnitVFX(Unit, "EnergizedBoon")
	Unit.Model.idle_speedup = IDLE_SPEEDUP_MULT
	Unit.Model.on_play_animation("Idle")
	Unit.stats("full_speed", speed, AppliedBy)
	print("Added")

func onRemove() -> void:
	var AppliedBy := AppliedByGD.new("EnergizedBoon")
	VFX.onRemoveUnitVFX(Unit, "EnergizedBoon")
	Unit.stats("full_speed", -speed, AppliedBy)
	Unit.Model.idle_speedup = 1
	Unit.Model.on_play_animation("Idle")
	print("Removed")
