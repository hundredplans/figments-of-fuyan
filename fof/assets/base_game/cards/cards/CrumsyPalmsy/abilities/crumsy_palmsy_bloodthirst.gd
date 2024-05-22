extends BloodthirstGD

@export var HEALTH: int = 1
func onBloodthirstCondition() -> bool: return charges > 0
func onBloodthirst() -> void:
	onGainStats(Unit, "health", HEALTH, AppliedBy)
	if is_visible: Unit.Model.on_play_animation("Ability")
	charges -= 1
