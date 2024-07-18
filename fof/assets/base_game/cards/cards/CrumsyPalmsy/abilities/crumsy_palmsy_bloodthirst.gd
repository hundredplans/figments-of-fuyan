extends BloodthirstGD

@export var HEALTH: int = 1
func onBloodthirstCondition() -> bool: return charges > 0
func onBloodthirst() -> void:
	if is_visible:
		Unit.Model.on_play_animation("Ability")
		onAbilityDelay(onAbilityDelayFinished)
	else: onAbilityDelayFinished()
	charges -= 1

func onAbilityDelayFinished() -> void:
	Units.changeStats(StatInfoGD.new(Unit, AppliedBy, StatsGD.BOTH_HEALTH, HEALTH))
