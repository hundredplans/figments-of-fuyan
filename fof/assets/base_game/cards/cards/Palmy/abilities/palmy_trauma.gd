extends TraumaGD

@export var SPEED_BUFF: int = 1
func onTrauma() -> void:
	onGainStats(Unit, "speed", SPEED_BUFF, AppliedBy)
	charges -= 1
	
func onTraumaCondition() -> bool:
	return charges > 0
