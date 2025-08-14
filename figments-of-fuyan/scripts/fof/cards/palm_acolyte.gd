extends CardGD
const DAMAGE_VALUE: int = 2

func onProcessAction(action: Action) -> void:
	super(action)

func getActiveEffectTiles(active_effect: ActiveEffectDatastore) -> ActiveEffectTiles:
	super(active_effect)
	if active_effect.name == "Divine Light":
		var tiles: Array = getVisibleTiles()
		return ActiveEffectTiles.new(tiles, tiles.filter(func(x: TileGD): return Game.getFieldCard(x) != null and x != Tile))
	return null

func onActiveEffect(active_effect: ActiveEffectDatastore, PickedTile: TileGD, active_effect_tiles: ActiveEffectTiles) -> void:
	super(active_effect, PickedTile, active_effect_tiles)
	if active_effect.name == "Divine Light":
		onAbility()
		
		var EnemyCard: CardGD = Game.getFieldCard(PickedTile)
		
		onForceAction(ChangeTileRotationAction.new(self, Game.getRelativeTileRotation(Tile, PickedTile)))
		onPushAction(DamageAction.new(self, EnemyCard, DAMAGE_VALUE, Game.DamageTypes.OTHER))
		
func onAIAbilityChecker(_active_effect: ActiveEffectDatastore, active_effect_tiles: ActiveEffectTiles, _dfl: DefaultFightLogic) -> TileGD:
	var enemies: Array = active_effect_tiles.pickable_tiles.map(func(x: TileGD): return Game.getFieldCard(x))
	if !enemies.is_empty():
		return enemies.pick_random().getTile()
	return null

func getDescription(use_default_values: bool = false) -> String:
	var active_effect: ActiveEffectDatastore = getActiveEffectByName("Divine Light")
	if !use_default_values and active_effect != null:
		return Helper.getDescriptionNumeric(super(), [active_effect.charges], [["ABILITY ", "[2]"]])
	return super(true)
