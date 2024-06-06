extends TargetAbilityGD

@export var ATTACK: int = 1
@export var HEAL: int = 1
func onTargetAbilityCondition() -> void:
	tiles = {"range": [], "affect": []}
	if charges > 0:
		tiles["range"] = Unit.getVisibleTiles()
		tiles["affect"] = tiles["range"].filter(func(x: TileGD): return Units.unit_by_tile_team_bool(x, Unit.team)) 

func onTargetAbility() -> void:
	var _Unit: UnitGD = Units.unit_by_tile(Tile)
	var AppliedBy := AppliedByGD.new("Ability", Unit)
	Combat.onApplyBuffNextTurn(BuffInfoGD.new(_Unit, AppliedBy, "attack", ATTACK))
	Combat.onApplyHealNextTurn(HealInfoGD.new(_Unit, AppliedBy, HEAL))
	
	if is_visible: Unit.Model.on_play_animation("Ability")
	Unit.Model._look_at(Tile)
	charges -= 1

func onTargetAbilityConditionAI() -> TileGD:
	var affected_units: Array = onAffectedUnits().filter(func(x: UnitGD): return x.turn_status == "TurnUnused" and x.team == Unit.team)
	var affectable_units: Array = []
	for _Unit in affected_units:
		if _Unit.isHealable():
			var units: Array = Combat.onFindEnemiesInMovementPaths(_Unit)
			units = units.filter(func(x: UnitGD): return Combat.onCalculateDamage(x, Unit.attack) <= x.health)
			if units.size() > 0: affectable_units.append(_Unit)
	if affectable_units.size() > 0: return affectable_units[randi() % affectable_units.size()].Tile
	return null
