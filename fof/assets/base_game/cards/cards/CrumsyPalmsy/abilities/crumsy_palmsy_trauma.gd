extends TraumaGD

@export var HEALTH: int = 1
func onTraumaCondition() -> bool: return true
func onTrauma(a: Dictionary) -> void:
	onGainStats(a.Unit, "health", HEALTH, a.AppliedBy)
	if a.is_visible: a.Unit.Model.on_play_animation("Ability")
