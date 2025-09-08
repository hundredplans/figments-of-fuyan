extends CardGD

const TIER_ONE_JUMP_HEIGHT: int = 3
const TIER_TWO_JUMP_HEIGHT: int = 5
const TIER_THREE_JUMP_HEIGHT: int = 5
const TIER_FOUR_JUMP_HEGIHT: int = 999

func onProcessAction(action: Action) -> void:
	super(action)

func getActiveEffectTiles(active_effect: ActiveEffectDatastore) -> ActiveEffectTiles:
	super(active_effect)
	if active_effect.name == "Highjump":
		var hdiff: int = getTierJumpHeight()
		var adjacent_tiles: Array = Game.getAdjacentTiles(Tile).filter(func(x: TileGD): return (x.getHeight() > Tile.getHeight() + 1) and x.getHeight() - Tile.getHeight() <= hdiff)
		var high_tiles: Array = adjacent_tiles.filter(func(x: TileGD): return !x.isOccupied() and !x.isSolid())
		return ActiveEffectTiles.new(adjacent_tiles, high_tiles)
	return null

func onActiveEffectPre(_active_effect: ActiveEffectDatastore, PickedTile: TileGD, _active_effect_tiles: ActiveEffectTiles) -> void:
	onForceAction(ChangeTileRotationAction.new(self, Game.getRelativeTileRotation(Tile, PickedTile)))

func getActiveEffectDisabled(_active_effect: ActiveEffectDatastore) -> bool:
	return false
	
func onAIAbilityChecker(_active_effect: ActiveEffectDatastore, active_effect_tiles: ActiveEffectTiles, _dfl: DefaultFightLogic, type := Game.AbilityAI.NULL) -> TileGD:
	return active_effect_tiles.pickable_tiles.pick_random()

func onActiveEffect(active_effect: ActiveEffectDatastore, PickedTile: TileGD, active_effect_tiles: ActiveEffectTiles) -> void:
	super(active_effect, PickedTile, active_effect_tiles)
	if active_effect.name == "Highjump":
		onPushAction(MovementAction.new(self, [Tile, PickedTile]))

func getTierJumpHeight() -> int:
	match tier:
		1: return TIER_ONE_JUMP_HEIGHT
		2: return TIER_TWO_JUMP_HEIGHT
		3: return TIER_THREE_JUMP_HEIGHT
		4: return TIER_FOUR_JUMP_HEGIHT
	return 0
