extends TargetAbilityGD

func onTargetAbilityCondition() -> void:
	tiles = {"range": [], "affect": []}
	tiles["range"] = Tiles.onFindUnitAdjacentTiles(Unit, 1)
	tiles["affect"] = tiles["range"].filter(func(x: TileGD): return Units.unit_by_tile_team_bool(x, Unit.team))

func onTargetAbility() -> void:
	Unit.Model._look_at(Tile)
	var AppliedBy := AppliedByGD.new("HelpfulHelmet", Unit)
	Unit.Model.death = "DeathAbility"
	Combat.onDestroyUnit(Unit, AppliedBy)
	Units.onAppendArgQueue(Combat.onHelpfulHelmetDelayed.bind({"Tile": Tile, "AppliedBy": AppliedBy}))
	
