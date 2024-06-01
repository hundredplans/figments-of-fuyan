extends TargetAbilityGD

@export var ATTACK: int = -1
@export var HEAL: int = 1
func onTargetAbilityCondition() -> void:
	tiles = {"range": [], "affect": []}
	if Units.on_units(TeamRelationGD.new(Unit.team, "Enemy")).any(func(x: UnitGD): return x.Tile in Unit.visible_tiles):
		tiles["range"] = Unit.getVisibleTiles()
		tiles["affect"] = tiles["range"].filter(func(x: TileGD): return Units.unit_by_tile_team_bool(x, Unit.team))
		
func onTargetAbility() -> void:
	var AppliedBy := AppliedByGD.new("Ability", Unit)
	if is_visible: Unit.Model._look_at(Tile); Unit.Model.on_play_animation("Ability")
	for _Unit in tiles["affect"].map(func(x: TileGD): return Units.unit_by_tile(x)):
		Combat.onApplyBuffNextTurn(BuffInfoGD.new(_Unit, AppliedBy, "attack", ATTACK))
		Combat.onHealAbility(_Unit, Unit, HEAL)
