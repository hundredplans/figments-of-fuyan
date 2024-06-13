extends RevengeGD

@export var HEAL: int = 1
func onRevenge() -> void:
	
	if is_visible:
		Unit.Model.on_play_animation("Ability")
		onAbilityDelay(onAbilityDelayFinished)
	else: onAbilityDelayFinished()

func onRevengeCondition() -> bool:
	return Unit.getVisibleAllies().any(func(x: UnitGD): return x.base_card.area_id == 1) and Unit.isHealable()
	
func onAbilityDelayFinished() -> void:
	Combat.onHealAbility(Unit, Unit, HEAL)
