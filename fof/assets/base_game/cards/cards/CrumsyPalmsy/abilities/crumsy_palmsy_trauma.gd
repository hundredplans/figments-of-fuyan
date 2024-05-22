extends TraumaGD

@export var HEALTH: int = 1
func onTraumaCondition() -> bool: return charges > 0
func onTrauma() -> void:
	onGainStats(Unit, "health", HEALTH, AppliedBy)
	if is_visible: Unit.Model.on_play_animation("Ability")
	charges -= 1
