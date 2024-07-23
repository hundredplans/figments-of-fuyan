extends TargetAbilityGD

@export var ATTACK: int = 1
@export var HEAL: int = 1

func onRefreshAbility() -> void:
	var in_range: Array = Unit.getVisibleTiles()
	AbilityTiles.setInfo(in_range, in_range.filter(func(x: TileGD): return Units.unit_by_tile_team_bool(x, Unit.team)))

func onTargetAbility() -> void:
	if is_visible:
		Unit.Model.on_play_animation("Ability")
		onAbilityDelay(onAbilityDelayFinished)
	else: onAbilityDelayFinished()
	Unit.Model._look_at(Tile)
	charges -= 1

@export var HEAL_UNIT_BEFORE_ODDS: float = 0.3
func onTargetAbilityConditionAI() -> TileGD:
	var units: Array = onAffectedUnits().filter(func(x: UnitGD): return x.turn_status == UnitGD.TURN_UNUSED)
	var _Tile: TileGD = onCanHealUnitsAI(units)
	if _Tile != null: return _Tile
	elif randf() < HEAL_UNIT_BEFORE_ODDS:
		units = onAffectedUnits().filter(func(x: UnitGD): return x.turn_status == UnitGD.TURN_USED)
		return onCanHealUnitsAI(units)
	return null

func onCanHealUnitsAI(affected_units: Array) -> TileGD:
	var affectable_units: Array = []
	for _Unit in affected_units:
		if _Unit.isHealable():
			var units: Array = Combat.onFindEnemiesInMovementPaths(_Unit)
			units = units.filter(func(x: UnitGD): return Combat.onCalculateDamage(x, Unit) <= x.health)
			if units.size() > 0: affectable_units.append(_Unit)
	if affectable_units.size() > 0: return affectable_units[randi() % affectable_units.size()].Tile
	return null
	
func onAbilityDelayFinished() -> void:
	var _Unit: UnitGD = Units.unit_by_tile(Tile)
	var AppliedBy := AppliedByGD.new(AppliedByGD.ABILITY, Unit)
	Units.changeStats(StatInfoGD.new(_Unit, AppliedBy, StatsGD.ATTACK, ATTACK, 1))
	Units.onDelayedStats(StatInfoGD.new(_Unit, AppliedBy, StatsGD.HEALTH, HEAL, 1, false, true, true))
	
