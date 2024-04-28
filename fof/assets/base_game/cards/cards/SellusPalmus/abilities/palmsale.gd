extends TargetAbilityGD

func onTargetAbilityCondition(Unit: UnitGD) -> Dictionary: # Returns valid Tiles
	var tiles: Dictionary = {}
	if charges > 0:
		tiles["range"] = Tiles.onFindUnitAdjacentTiles(Unit, 1)
		tiles["affect"] = tiles["range"].filter(func(x: TileGD): return Units.unit_by_tile_team_bool(x, Unit.team))
	return tiles
	
func onTargetAbility(is_visible: bool, Unit: UnitGD, Tile: TileGD, tiles: Dictionary) -> void:
	for _Unit in tiles["affect"].map(func(x: TileGD): return Units.unit_by_tile(x)):
		var Healee: UnitGD = _Unit
		var healInfo := HealInfoGD.new()
		healInfo.heal = 1
		
		var AppliedBy := AppliedByGD.new()
		AppliedBy.type = "Ability"
		AppliedBy.Applier = Unit
		healInfo.AppliedBy = AppliedBy
		
		healInfo.Healee = Healee
		Combat.onHeal(healInfo)
		
	if is_visible: Unit.Model.on_play_animation("Ability")
	charges -= 1
