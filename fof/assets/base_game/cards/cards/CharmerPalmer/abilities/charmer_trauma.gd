extends TraumaGD

@export var ATTACK: int = 1
var healed_allies: Array = []
func onTraumaCondition() -> bool:
	return Deather in healed_allies
	
func onTrauma() -> void:
	Units.changeStats(StatInfoGD.new(Unit, AppliedBy, StatsGD.ATTACK, ATTACK))
	Unit.onChangeAIStat("aic", 1)
