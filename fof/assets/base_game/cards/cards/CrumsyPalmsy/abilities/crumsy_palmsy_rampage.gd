extends RampageGD

@export var HEALTH: int = 1
func onRampageCondition(_a: Dictionary) -> bool: return charges > 0
func onRampage(a: Dictionary) -> void:
	onGainStats(a.Unit, "health", HEALTH, a.AppliedBy)
	if a.is_visible: a.Unit.Model.on_play_animation("Ability")
	charges -= 1
