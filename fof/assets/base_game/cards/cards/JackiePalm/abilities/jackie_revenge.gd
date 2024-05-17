extends RevengeGD

@export var HEAL: int = 1
func onRevenge(a: Dictionary) -> void:
	Combat.onHealAbility(a.Unit, a.Unit, HEAL)
	if a.is_visible: a.Unit.Model.on_play_animation("Ability")

func onRevengeCondition(a: Dictionary) -> bool:
	return a.Unit.getVisibleAllies().any(func(x: UnitGD): return x.base_card.area_id == 1) and a.Unit.isHealable()
	
