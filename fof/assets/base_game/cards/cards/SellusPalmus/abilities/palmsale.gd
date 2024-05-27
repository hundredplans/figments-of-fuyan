extends TargetAbilityGD

@export var HEAL: int = 1
func onTargetAbilityCondition() -> void: # Returns valid Tiles
	tiles = {"range": [], "affect": []}
	if charges > 0:
		tiles["range"] = Tiles.onFindUnitAdjacentTiles(Unit, 1)
		tiles["affect"] = tiles["range"].filter(func(x: TileGD): return Units.unit_by_tile_team_bool(x, Unit.team))
	
func onTargetAbility() -> void:
	Unit.Model._look_at(Tile)
	for _Unit in tiles["affect"].map(func(x: TileGD): return Units.unit_by_tile(x)):
		Combat.onHealAbility(_Unit, Unit, HEAL)
	if is_visible: Unit.Model.on_play_animation("Ability")
	charges -= 1
