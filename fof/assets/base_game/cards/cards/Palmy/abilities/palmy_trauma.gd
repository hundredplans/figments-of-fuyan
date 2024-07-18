extends TraumaGD

@export var SPEED_BUFF: int = 1
func onTrauma() -> void:
	Units.changeStats(StatInfoGD.new(Unit, AppliedBy, StatsGD.BOTH_SPEED, SPEED_BUFF))
	charges -= 1
	
func onTraumaCondition() -> bool:
	return charges > 0
