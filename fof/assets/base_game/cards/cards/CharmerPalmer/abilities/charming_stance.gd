extends TargetAbilityGD

@export var HEAL: int = 1

func onTargetAbilityCondition(a: Dictionary) -> Dictionary:
	var tiles: Dictionary = {"range": [], "affect": []}
	if charges > 0:
		tiles["range"] = a.Unit.getVisibleTiles()
		tiles["affect"] = tiles["range"].filter(func(x: TileGD): return Units.unit_by_tile_team_bool(x, a.Unit.team)) 
	return tiles
	
func onTargetAbility(a: Dictionary) -> void:
	var healed_allies: Array = a.tiles["affect"].map(func(x: TileGD): return Units.unit_by_tile(x))
	var trauma_ability: AbilityGD = Combat.onFindAbility(a.Unit, "CharmerTrauma")
	if trauma_ability != null: trauma_ability.healed_allies += healed_allies
	
	for Unit in healed_allies:
		a.Unit.Model._look_at(a.Tile)
		if Combat.onHealAbility(Unit, a.Unit, HEAL):
			GameEffects.onAddGameFX(Unit, "CharmingStance", {"Unit": a.Unit})
	if a.is_visible: a.Unit.Model.on_play_animation("Ability")
	charges -= 1
