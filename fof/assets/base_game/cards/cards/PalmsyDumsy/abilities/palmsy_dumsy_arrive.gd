extends ArriveGD

@export var SELF_DAMAGE: int = 2
func onArrive() -> void:
	Combat.onDMG(Unit, AppliedByGD.new("Ability", Unit), SELF_DAMAGE)
