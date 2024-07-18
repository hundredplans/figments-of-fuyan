extends ArriveGD

@export var SELF_DAMAGE: int = 2
func onArrive() -> void:
	Combat.onDMG(Unit, AppliedByGD.new(AppliedByGD.ABILITY, Unit), SELF_DAMAGE)
