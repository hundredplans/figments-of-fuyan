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
			GameEffects.onAddGameFX(_Unit, "CharmingStance", {"Unit": Unit})
	if is_visible: Unit.Model.on_play_animation("Ability")
	charges -= 1
