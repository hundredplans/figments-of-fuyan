class_name StatInfoGD
extends Resource

var Boons: BoonsGD

var Unit: UnitGD
var AppliedBy: AppliedByGD
var value: int
# -1 = infinite
var turns: int
# Enum of StatsGD
var stat_type: int
# Use if it needs to change the stat to it specifically rather than add / minus
var absolute: bool

func _init(_Unit: UnitGD = null, _AppliedBy: AppliedByGD = null, _stat_type: int = 0, _value: int = 0, _turns: int = -1, _absolute: bool = false) -> void:
	Unit = _Unit
	AppliedBy = _AppliedBy
	stat_type = _stat_type
	value = _value
	turns = _turns
	absolute = _absolute

func onApplyModifiers() -> void:
	if Unit.team == 0 and value > 0 and !absolute and stat_type not in [StatsGD.HEALTH, StatsGD.CURRENT_SPEED]:
		var boon: BoonGD = Boons.onFindBoon(Boons.onFindAllBoon(3))
		if boon != null: value = boon.onCustomTrigger(value)

func getStatName() -> String:
	match stat_type:
		StatsGD.ATTACK: return "Attack"
		StatsGD.HEALTH, StatsGD.MAX_HEALTH, StatsGD.BOTH_HEALTH: return "Health"
		_: return "Speed"
