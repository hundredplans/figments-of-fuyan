extends CardGD
const DAMAGE_VALUE: int = 2

func onProcessAction(action: Action) -> void:
	super(action)

func getActiveEffectTiles() -> ActiveEffectTiles:
	var tiles: Array = getVisibleTiles()
	return ActiveEffectTiles.new(tiles, tiles.filter(func(x: TileGD): return Game.getFieldCard(x) != null and x != Tile))

func onActiveEffect(PickedTile: TileGD, active_effect_tiles: ActiveEffectTiles) -> void:
	onAbility()
	
	var EnemyCard: CardGD = Game.getFieldCard(PickedTile)
	
	onForceAction(ChangeTileRotationAction.new(self, Game.getRelativeTileRotation(Tile, PickedTile)))
	onPushAction(DamageAction.new(self, EnemyCard, DAMAGE_VALUE, Game.DamageTypes.OTHER))
		
func onAIAbilityChecker(active_effect_tiles: ActiveEffectTiles, _dfl: DefaultFightLogic, type := Game.AbilityAI.NULL) -> TileGD:
	var enemies: Array = active_effect_tiles.pickable_tiles.map(func(x: TileGD): return Game.getFieldCard(x))
	if !enemies.is_empty():
		return enemies.pick_random().getTile()
	return null

func getDescription(use_default_values: bool = false) -> String:
	if !use_default_values:
		return Helper.getDescription(super(), [active_effect_charges])
	return super(true)
