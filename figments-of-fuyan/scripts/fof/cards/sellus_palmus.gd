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
	if active_effect.name == "Palmsale":
		var cards: Array = active_effect_tiles.pickable_tiles.map(func(x: TileGD): return Game.getFieldCard(x))
		var actions: Array = [HealAction.new(cards.map(func(x: CardGD): return HealDatastore.new(x, 1))),\
		ChangeTileRotationAction.new(self, Game.getRelativeTileRotation(Tile, PickedTile))]
		
		onPushAction(actions)
		onAbility()
	
# If it can hit two or more allies
func onAIAbilityChecker(_active_effect: ActiveEffectDatastore, active_effect_tiles: ActiveEffectTiles, _dfl: DefaultFightLogic) -> TileGD:
	return active_effect_tiles.pickable_tiles.pick_random() if active_effect_tiles.pickable_tiles.size() >= AMOUNT_TO_USE_HEAL_AI else null
	
func getDescription(use_default_values: bool = false) -> String:
	var active_effect: ActiveEffectDatastore = getActiveEffectByName("Palmsale")
	if !use_default_values and active_effect != null:
		return Helper.getDescription(super(), [active_effect.charges])
	return super(true)
	
const BONUS_PER_ADJACENT_ALLY_ON_TILE: float = 0.25
# +0.25 per unit sellus is adjacent to on a tile
func onUnitSpecificTransforms(tiles_to_value: Dictionary, DFL: DefaultFightLogic) -> void:
	for TransformTile: TileGD in tiles_to_value:
		var adjacency_bonus: float = DFL.getAllies().filter(func(x: CardGD): return Game.isAdjacent(x.getTile(), TransformTile)).size() * BONUS_PER_ADJACENT_ALLY_ON_TILE
		tiles_to_value[TransformTile] += adjacency_bonus
