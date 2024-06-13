extends RampageGD

@export var HEALTH: int = 1
func onRampageCondition() -> bool: return charges > 0
func onRampage() -> void:
	if is_visible:
		Unit.Model.on_play_animation("Ability")
		onAbilityDelay(onAbilityDelayFinished)
	else: onAbilityDelayFinished()
	charges -= 1

func onAbilityDelayFinished() -> void:
	onGainStats(Unit, "health", HEALTH, AppliedBy)
