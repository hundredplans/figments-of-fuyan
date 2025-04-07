extends CardGD

const REVEAL_ID: int = 6
const REVEAL_TURNS: int = 3
func onProcessAction(action: Action) -> void:
	super(action)

func getActiveEffectTiles(active_effect: ActiveEffectDatastore) -> ActiveEffectTiles:
	super(active_effect)
	if active_effect is ActiveAbilityDatastore and active_effect.name == "Divine Light":
		var tiles: Array = getVisibleTiles()
		return ActiveEffectTiles.new(tiles, tiles.filter(func(x: TileGD): return Game.getEnemyFieldCard(x, team) != null))
	return null

func onActiveEffect(active_effect: ActiveEffectDatastore, PickedTile: TileGD, active_effect_tiles: ActiveEffectTiles) -> void:
	super(active_effect, PickedTile, active_effect_tiles)
	if active_effect is ActiveAbilityDatastore and active_effect.name == "Divine Light":
		onAbility()
		
		var actions: Array = []
		var EnemyCard: CardGD = Game.getFieldCard(PickedTile)
		
		actions.append(EnemyCard.getBaseStatusEffectAction(REVEAL_ID, REVEAL_TURNS))
		
		onForceAction(ChangeTileRotationAction.new(self, Game.getRelativeTileRotation(Tile, PickedTile)))
		onPushAction(actions)
		
func onAIAbilityChecker(_active_effect: ActiveEffectDatastore, active_effect_tiles: ActiveEffectTiles, _dfl: DefaultFightLogic) -> TileGD:
	return active_effect_tiles.pickable_tiles.pick_random()

func getDescription() -> String:
	var active_effect: ActiveEffectDatastore = getActiveEffectByName("Divine Light")
	if active_effect != null:
		return Helper.getDescriptionNumeric(super(), [active_effect.charges], [["ABILITY ", "[2]"]])
	return super()
