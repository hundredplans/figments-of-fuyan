extends TargetAbilityGD

func onTargetAbilityCondition(a: Dictionary) -> Dictionary:
	var tiles: Dictionary = {"range": [], "affect": []}
	tiles["range"] = Tiles.onFindUnitAdjacentTiles(a.Unit, 1)
	tiles["affect"] = tiles["range"].filter(func(x: TileGD): return Units.unit_by_tile_team_bool(x, a.Unit.team))
	return tiles

func onTargetAbility(a: Dictionary) -> void:
	a.Unit.Model._look_at(a.Tile)
	var AppliedBy := AppliedByGD.new("Ability", a.Unit)
	a["AppliedBy"] = AppliedBy
	
	a.Unit.Model.death = "DeathAbility"
	Combat.onDestroyUnit(a.Unit, AppliedBy)
	Units.onAppendArgQueue(Combat.onHelpfulHelmetDelayed.bind(a))
	
