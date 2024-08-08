class_name DeathTriggerInfoGD
extends TriggerInfoGD

# The killer
var AppliedBy: AppliedByGD
func _init(_AppliedBy: AppliedByGD = null) -> void:
	AppliedBy = _AppliedBy
