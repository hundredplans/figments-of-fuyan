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

@export var GUARANTEE_HEAL: int = 2
@export var TEAMWORK_MULT: float = 0.13
func onTargetAbilityConditionAI() -> TileGD:
	var healable_units: Array = []
	for _Tile in tiles["affect"]:
		var _Unit: UnitGD = Units.unit_by_tile(_Tile)
		if _Unit.isHealable():
			healable_units.append(_Unit)
	
	if healable_units.size() >= GUARANTEE_HEAL:
		return healable_units[randi() % healable_units.size()].Tile
	elif healable_units.size() == 1:
		var roll: float = randf()
		if roll <= (Unit.base_card.ait * TEAMWORK_MULT):
			return healable_units[0].Tile
	return null
