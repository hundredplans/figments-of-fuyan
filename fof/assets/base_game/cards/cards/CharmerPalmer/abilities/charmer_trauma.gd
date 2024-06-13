extends TraumaGD

@export var ATTACK: int = 1
var healed_allies: Array = []
func onTraumaCondition() -> bool:
	return Deather in healed_allies
	
func onTrauma() -> void:
	onGainStats(Unit, "attack", ATTACK, AppliedBy)
	Unit.onChangeAIStat("aic", 1)
