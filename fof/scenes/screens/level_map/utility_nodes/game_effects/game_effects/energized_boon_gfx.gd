extends GameFXGD

@export var IDLE_SPEEDUP_MULT: float = 2
var speed: int
func onCreateGFX() -> void:
	custom_triggers = [
		TriggerGD.new(self, Unit, onRemove, TriggerGD.NEXT_TURN, TriggerGD.REMOVE_FX)
	]
	var AppliedBy := AppliedByGD.new(AppliedByGD.BOON)
	VFX.onCreateUnitVFX(Unit, "EnergizedBoon")
	Unit.Model.idle_speedup = IDLE_SPEEDUP_MULT
	Unit.Model.on_play_animation("Idle")
	Units.changeStats(StatInfoGD.new(Unit, AppliedBy, StatsGD.BOTH_SPEED, speed, 1))

func onRemove() -> void:
	VFX.onRemoveUnitVFX(Unit, "EnergizedBoon")
	Unit.Model.idle_speedup = 1
	Unit.Model.on_play_animation("Idle")
