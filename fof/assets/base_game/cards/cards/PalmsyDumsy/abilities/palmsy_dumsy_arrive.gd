extends ArriveGD

@export var SELF_DAMAGE: int = 2
func onArrive(a: Dictionary) -> void:
	var AppliedBy := AppliedByGD.new()
	AppliedBy.type = "Ability"
	AppliedBy.Applier = a.Unit
	Combat.onDMG(a.Unit, AppliedBy, SELF_DAMAGE)
