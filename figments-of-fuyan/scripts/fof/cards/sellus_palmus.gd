extends CardGD

const AMOUNT_TO_USE_HEAL_AI: int = 2

func getActiveEffectTiles(active_effect: ActiveEffectDatastore) -> ActiveEffectTiles:
	if active_effect.name == "Palmsale":
		var tiles: Array = Game.getAdjacentTiles(Tile)
		var pickable_tiles: Array = tiles.filter(isPickable)
		return ActiveEffectTiles.new(tiles, pickable_tiles)
	return null
	
func isPickable(_Tile: TileGD) -> bool:
	var Card: CardGD = Game.getAllyFieldCard(_Tile, team)
	return Card != null and Card.isHealable()
		
func onActiveEffect(active_effect: ActiveEffectDatastore, PickedTile: TileGD, active_effect_tiles: ActiveEffectTiles) -> void:
	super(active_effect, PickedTile, active_effect_tiles)
	if active_effect is ActiveAbilityDatastore and active_effect.name == "Palmsale":
		var stat_infos: Array = active_effect_tiles.pickable_tiles.map(func(x: TileGD): return StatInfo.new(Game.getFieldCard(x), Game.Stats.HEALTH, 1))
		var actions: Array = [StatAction.new(stat_infos),\
		ChangeTileRotationAction.new(self, Game.getRelativeTileRotation(Tile, PickedTile))]
		
		onPushAction(actions)
		onAbility()
	
# If it can hit two or more allies
func onAIAbilityChecker(_active_effect: ActiveEffectDatastore, active_effect_tiles: ActiveEffectTiles, _dfl: DefaultFightLogic) -> TileGD:
	return active_effect_tiles.pickable_tiles.pick_random() if active_effect_tiles.pickable_tiles.size() >= AMOUNT_TO_USE_HEAL_AI else null
	
func getDescription() -> String:
	var active_effect: ActiveEffectDatastore = getActiveEffectByName("Palmsale")
	if active_effect != null:
		var number: String = "[1]" if !ascended else "[2]"
		return Helper.getDescriptionNumeric(super(), [active_effect.charges], [["ABILITY ", number]])
	return super()
	
const BONUS_PER_ADJACENT_ALLY_ON_TILE: float = 0.25
# +0.25 per unit sellus is adjacent to on a tile
func onUnitSpecificTransforms(tiles_to_value: Dictionary, DFL: DefaultFightLogic) -> void:
	for Tile in tiles_to_value:
		var adjacency_bonus: int = DFL.getAllies().filter(func(x: CardGD): return Game.isAdjacent(x.getTile(), Tile)).size() * BONUS_PER_ADJACENT_ALLY_ON_TILE
		tiles_to_value[Tile] += adjacency_bonus
