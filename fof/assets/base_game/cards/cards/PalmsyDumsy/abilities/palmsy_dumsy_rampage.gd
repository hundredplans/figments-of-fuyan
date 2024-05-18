extends RampageGD

@export var HEAL: int = 1
func onRampageCondition(_a: Dictionary) -> bool: return true
func onRampage(a: Dictionary) -> void:
	var healable_allies: Array = a.Unit.getVisibleAllies()
	for _Unit in healable_allies + [a.Unit]:
		Combat.onHealAbility(_Unit, a.Unit, HEAL)
