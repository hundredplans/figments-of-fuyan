extends TargetAbilityGD

@export var ATTACK: int = -1
@export var HEAL: int = 1
func onTargetAbilityCondition() -> void:
	tiles = {"range": [], "affect": []}
	if Units.on_units(TeamRelationGD.new(Unit.team, "Enemy")).any(func(x: UnitGD): return x.Tile in Unit.visible_tiles):
		tiles["range"] = Unit.getVisibleTiles()
		tiles["affect"] = tiles["range"].filter(func(x: TileGD): return Units.unit_by_tile_team_bool(x, Unit.team))
		
func onTargetAbility() -> void:
	Unit.Model._look_at(Tile)
	if is_visible:
		Unit.Model.on_play_animation("Ability")
		onAbilityDelay(onAbilityDelayFinished)
	else: onAbilityDelayFinished()
@export var SINGLE_HEAL_ODDS: float = 0.1
@export var AI_HEAL_COUNT: int = 2
func onTargetAbilityConditionAI() -> TileGD:
	var heal_count: int = 0
	for _Tile in tiles["affect"]:
		var _Unit: UnitGD = Units.unit_by_tile(_Tile)
		if _Unit.isHealable(): heal_count += 1
		
	if heal_count >= AI_HEAL_COUNT or (heal_count == 1 and randf() < SINGLE_HEAL_ODDS):
		return tiles["affect"][randi() % tiles["affect"].size()]
		
	return null

func onAbilityDelayFinished() -> void:
	var AppliedBy := AppliedByGD.new("Ability", Unit)
	for _Unit in tiles["affect"].map(func(x: TileGD): return Units.unit_by_tile(x)):
		Combat.onApplyBuffNextTurn(BuffInfoGD.new(_Unit, AppliedBy, "attack", ATTACK))
		Combat.onHealAbility(_Unit, Unit, HEAL)
