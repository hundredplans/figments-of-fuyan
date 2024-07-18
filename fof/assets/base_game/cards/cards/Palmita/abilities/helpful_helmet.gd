extends TargetAbilityGD
func onTargetAbilityCondition() -> void:
	tiles = {"range": [], "affect": []}
	tiles["range"] = Tiles.onFindUnitAdjacentTiles(Unit, 1)
	tiles["affect"] = tiles["range"].filter(func(x: TileGD): return Units.unit_by_tile_team_bool(x, Unit.team))

func onTargetAbility() -> void:
	Unit.Model._look_at(Tile)
	var AppliedBy := AppliedByGD.new(AppliedByGD.HELPFUL_HELMET, Unit)
	Unit.Model.death = "DeathAbility"
	Combat.onDestroyUnit(Unit, AppliedBy)
	var is_vis: bool = Unit.team == 0 or Unit.Tile in Vision.getTeamVision()
	ActionManager.onAddAction(DelayActionGD.new(Combat.onHelpfulHelmetDelayed.bind({"Tile": Tile, "AppliedBy": AppliedBy}), is_vis))
	
@export var DANGER_LIST_MIN: int = 37
func onTargetAbilityConditionAI() -> TileGD:
	if Unit.Tile in Vision.getTeamVision():
		var danger_list: Array = AIManager.getDangerList(Unit, onAffectedUnits())
		if danger_list.size() > 0 and danger_list[0].danger >= DANGER_LIST_MIN:
			return danger_list[0].Unit.Tile
	return null
