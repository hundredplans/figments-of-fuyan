extends RevengeGD

@export var HEAL: int = 1
func onRevenge(a: Dictionary) -> void:
	var heal_self: bool = a.Unit.getVisibleAllies().any(func(x: UnitGD): return x.base_card.area_id == 1)
	if heal_self: 
		Combat.onHealAbility(a.Unit, a.Unit, HEAL)
		if a.is_visible: a.Unit.Model.on_play_animation("Ability")
