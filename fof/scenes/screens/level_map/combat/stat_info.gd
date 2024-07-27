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
# True for reverse buffs that return the value exactly
var unmodifiable: bool
var show_change: bool
# Doesn't reverse the buff when it reaches 0 turns
var is_delayed: bool

func _init(_Unit: UnitGD = null, _AppliedBy: AppliedByGD = null, _stat_type: int = 0, _value: int = 0, _turns: int = -1, _absolute: bool = false, _show_change: bool = true, _is_delayed: bool = false) -> void:
	Unit = _Unit
	AppliedBy = _AppliedBy
	stat_type = _stat_type
	value = _value
	turns = _turns
	absolute = _absolute
	show_change = _show_change
	is_delayed = _is_delayed

func onApplyModifiers() -> void:
	if !unmodifiable and Unit.team == 0 and value > 0 and !absolute:
		if stat_type not in [StatsGD.HEALTH, StatsGD.CURRENT_SPEED]:
			var boon: BoonGD = Boons.onFindBoon(Boons.onFindAllBoon(3))
			if boon != null: value = boon.onCustomTrigger(value)
			
		if stat_type == StatsGD.HEALTH: value *= Unit.heal_multiplier

func getStatName() -> String:
	match stat_type:
		StatsGD.ATTACK: return "Attack"
		StatsGD.HEALTH, StatsGD.MAX_HEALTH, StatsGD.BOTH_HEALTH: return "Health"
		_: return "Speed"

static func getStatTypeStatic(stat: String) -> int:
	stat = stat.to_lower()
	match stat:
		"speed": return StatsGD.BOTH_SPEED
		"health": return StatsGD.BOTH_HEALTH
		"attack": return StatsGD.ATTACK
	return 0
	
func add(_value: int) -> void:
	value += _value
	
func getReverse() -> StatInfoGD:
	var stat_info := StatInfoGD.new(Unit, AppliedBy, stat_type, value * -1, turns, absolute, show_change)
	stat_info.unmodifiable = true
	return stat_info

func getDelayed() -> StatInfoGD:
	return StatInfoGD.new(Unit, AppliedBy, stat_type, value, turns, absolute, show_change)

func getGeneralStatType() -> int:
	match stat_type:
		StatsGD.ATTACK: return StatsGD.ATTACK
		StatsGD.HEALTH, StatsGD.BOTH_HEALTH, StatsGD.MAX_HEALTH: return StatsGD.BOTH_HEALTH
		StatsGD.CURRENT_SPEED, StatsGD.BOTH_SPEED, StatsGD.MAX_SPEED: return StatsGD.BOTH_SPEED
	return -1
