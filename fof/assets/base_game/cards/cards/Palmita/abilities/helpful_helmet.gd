extends TargetAbilityGD

func onTargetAbilityCondition(a: Dictionary) -> Dictionary:
	var tiles: Dictionary = {"range": [], "affect": []}
	tiles["range"] = Tiles.onFindUnitAdjacentTiles(a.Unit, 1)
	tiles["affect"] = tiles["range"].filter(func(x: TileGD): return Units.unit_by_tile_team_bool(x, a.Unit.team))
	return tiles

func onTargetAbility(a: Dictionary) -> void:
	var Unit: UnitGD = Units.unit_by_tile(a.Tile)
	var AppliedBy := AppliedByGD.new()
	AppliedBy.type = "Ability"
	AppliedBy.Applier = a.Unit
	GameEffects.onAddGameFX(Unit, "HelpfulHelmet", {"AppliedBy": AppliedBy, "use_bound": false})
	onGainStats(Unit, "health", 1, AppliedBy)
	
	a.Unit.Model._look_at(a.Tile)
	a.Unit.Model.death = "DeathAbility"
	Combat.onDestroyUnit(a.Unit, AppliedBy)
	
