extends RampageGD

@export var HEAL: int = 1
func onRampageCondition() -> bool: return true
func onRampage() -> void:
	var healable_allies: Array = Unit.getVisibleAllies()
	for _Unit in healable_allies + [Unit]:
		Combat.onHealAbility(_Unit, Unit, HEAL)
