extends BloodthirstGD

@export var HEALTH: int = 1
func onBloodthirstCondition(a: Dictionary) -> bool: return true
func onBloodthirst(a: Dictionary) -> void:
	onGainStats(a.Unit, "health", HEALTH, a.AppliedBy)
	if a.is_visible: a.Unit.Model.on_play_animation("Ability")
