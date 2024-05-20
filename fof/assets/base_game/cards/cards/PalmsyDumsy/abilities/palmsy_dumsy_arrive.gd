extends ArriveGD

@export var SELF_DAMAGE: int = 2
func onArrive(a: Dictionary) -> void:
	Combat.onDMG(a.Unit, AppliedByGD.new("Ability", a.Unit), SELF_DAMAGE)
