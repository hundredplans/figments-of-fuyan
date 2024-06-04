extends TargetAbilityGD
@export var AI_LIST: Array[BaseCardGD]
func onTargetAbilityCondition() -> void:
	tiles = {"range": [], "affect": []}
	tiles["range"] = Tiles.onFindUnitAdjacentTiles(Unit, 1)
	tiles["affect"] = tiles["range"].filter(func(x: TileGD): return Units.unit_by_tile_team_bool(x, Unit.team))

func onTargetAbility() -> void:
	Unit.Model._look_at(Tile)
	var AppliedBy := AppliedByGD.new("HelpfulHelmet", Unit)
	Unit.Model.death = "DeathAbility"
	Combat.onDestroyUnit(Unit, AppliedBy)
	Units.onAppendArgQueue(Combat.onHelpfulHelmetDelayed.bind({"Tile": Tile, "AppliedBy": AppliedBy}))
	
func onTargetAbilityConditionAI() -> TileGD:
	var tiles_in_ai_list: Array = []
	for _Tile in tiles["affect"]:
		var _Unit: UnitGD = Units.unit_by_tile(_Tile)
		if _Unit.base_card.id in AI_LIST.map(func(x: BaseCardGD): return x.id): tiles_in_ai_list.append(_Tile)
	
	if !tiles_in_ai_list.is_empty():
		return tiles_in_ai_list[randi() % tiles_in_ai_list.size()]
	return null
