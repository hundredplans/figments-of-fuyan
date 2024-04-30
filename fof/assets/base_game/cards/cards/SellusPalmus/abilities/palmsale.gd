extends TargetAbilityGD

@export var HEAL: int = 1
func onTargetAbilityCondition(a: Dictionary) -> Dictionary: # Returns valid Tiles
	var tiles: Dictionary = {}
	if charges > 0:
		tiles["range"] = Tiles.onFindUnitAdjacentTiles(a.Unit, 1)
		tiles["affect"] = tiles["range"].filter(func(x: TileGD): return Units.unit_by_tile_team_bool(x, a.Unit.team))
	return tiles
	
func onTargetAbility(a: Dictionary) -> void:
	for _Unit in a.tiles["affect"].map(func(x: TileGD): return Units.unit_by_tile(x)):
		Combat.onHealAbility(_Unit, a.Unit, HEAL)
		a.Unit.Model._look_at(a.Tile)
	if a.is_visible: a.Unit.Model.on_play_animation("Ability")
	charges -= 1
