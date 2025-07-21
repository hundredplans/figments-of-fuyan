extends CardGD

const UNASCENDED_HEIGHT_DIFF: int = 3
const ASCENDED_HEIGHT_DIFF: int = 5
func onProcessAction(action: Action) -> void:
	super(action)

func getActiveEffectTiles(active_effect: ActiveEffectDatastore) -> ActiveEffectTiles:
	super(active_effect)
	if active_effect is ActiveAbilityDatastore and active_effect.name == "Highjump":
		var hdiff: int = 3 if !ascended else 5
		var adjacent_tiles: Array = Game.getAdjacentTiles(Tile).filter(func(x: TileGD): return (x.getHeight() > Tile.getHeight() + 1) and x.getHeight() - Tile.getHeight() <= hdiff)
		var high_tiles: Array = adjacent_tiles.filter(func(x: TileGD): return !x.isOccupied() and !x.isSolid())
		return ActiveEffectTiles.new(adjacent_tiles, high_tiles)
	return null

func onActiveEffectPre(_active_effect: ActiveEffectDatastore, PickedTile: TileGD, _active_effect_tiles: ActiveEffectTiles) -> void:
	onForceAction(ChangeTileRotationAction.new(self, Game.getRelativeTileRotation(Tile, PickedTile)))

func getActiveEffectDisabled(_active_effect: ActiveEffectDatastore) -> bool:
	return false
	
func onAIAbilityChecker(_active_effect: ActiveEffectDatastore, active_effect_tiles: ActiveEffectTiles, _dfl: DefaultFightLogic) -> TileGD:
	return active_effect_tiles.pickable_tiles.pick_random()

func onActiveEffect(active_effect: ActiveEffectDatastore, PickedTile: TileGD, active_effect_tiles: ActiveEffectTiles) -> void:
	super(active_effect, PickedTile, active_effect_tiles)
	if active_effect is ActiveAbilityDatastore and active_effect.name == "Highjump":
		onPushAction(MovementAction.new(self, [Tile, PickedTile]))
