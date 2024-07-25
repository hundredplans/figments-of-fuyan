extends ToolGD

@export var heal: int = 1
@export var distance: int = 1
var healed_units: Array = []
var units_to_heal: Array = []
func onAbilityTrigger(_ability: ToolAbilityInfoGD) -> void:
	var AppliedBy := AppliedByGD.new(AppliedByGD.TOOL, self)
		
	for _Unit in units_to_heal:
		Combat.onHeal(HealInfoGD.new(_Unit, heal, AppliedBy))
		healed_units.append(_Unit)

func onCondition(_ability: ToolAbilityInfoGD) -> bool:
	if !is_ascended: units_to_heal = Units.onFindAdjacentUnits(Unit, distance).filter(func(x: UnitGD): return x.team == Unit.team)
	else: units_to_heal = Unit.getVisibleAllies()
	
	units_to_heal = units_to_heal.filter(func(x: UnitGD): return x not in healed_units and x.isHealable())
	return !units_to_heal.is_empty()
