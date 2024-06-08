extends TargetAbilityGD

@export var HEAL: int = 1

func onTargetAbilityCondition() -> void:
	tiles = {"range": [], "affect": []}
	if charges > 0:
		tiles["range"] = Unit.getVisibleTiles()
		tiles["affect"] = tiles["range"].filter(func(x: TileGD): return Units.unit_by_tile_team_bool(x, Unit.team)) 
	
func onTargetAbility() -> void:
	var healed_allies: Array = tiles["affect"].map(func(x: TileGD): return Units.unit_by_tile(x))
	var trauma_ability: AbilityGD = Combat.onFindAbility(Unit, "CharmerTrauma")
	if trauma_ability != null: trauma_ability.healed_allies += healed_allies
	
	for _Unit in healed_allies:
		Unit.Model._look_at(Tile)
		if Combat.onHealAbility(_Unit, Unit, HEAL):
			GameEffects.onAddGameFX(_Unit, GameFXGD.CHARMING_STANCE, {"Unit": Unit})
	if is_visible: Unit.Model.on_play_animation("Ability")
	charges -= 1

@export var SINGLE_HEAL_ODDS: float = 0.1
@export var GUARANTEE_HEAL: int = 2
func onTargetAbilityConditionAI() -> TileGD:
	var healable_units: Array = []
	for _Tile in tiles["affect"]:
		var _Unit: UnitGD = Units.unit_by_tile(_Tile)
		if _Unit.isHealable():
			healable_units.append(_Unit)
	
	if healable_units.size() >= GUARANTEE_HEAL or (healable_units.size() == 1 and randf() < SINGLE_HEAL_ODDS):
		return healable_units[randi() % healable_units.size()].Tile
	return null
