extends RampageGD

@export var HEALTH: int = 1
func onRampageCondition() -> bool: return charges > 0
func onRampage() -> void:
	onGainStats(Unit, "health", HEALTH, AppliedBy)
	if is_visible: Unit.Model.on_play_animation("Ability")
	charges -= 1
