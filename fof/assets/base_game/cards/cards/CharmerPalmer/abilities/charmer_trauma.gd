extends TraumaGD

@export var ATTACK: int = 1
var healed_allies: Array = []
func onTraumaCondition(a: Dictionary) -> bool:
	return a.Deather in healed_allies
	
func onTrauma(a: Dictionary) -> void:
	onGainStats(a.Unit, "attack", ATTACK, a.AppliedBy)
