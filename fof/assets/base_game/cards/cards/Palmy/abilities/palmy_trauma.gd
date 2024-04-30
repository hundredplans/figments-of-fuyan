extends TraumaGD

@export var SPEED_BUFF: int = 1
func onTrauma(a: Dictionary) -> void:
	onGainStats(a.Unit, "speed", SPEED_BUFF, a.AppliedBy)
	charges -= 1
	
func onTraumaCondition() -> bool:
	return charges > 0
