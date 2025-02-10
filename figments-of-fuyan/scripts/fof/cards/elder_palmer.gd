extends CardGD

const GUARANTEED_HEAL_UNIT_AMOUNT_AI: int = 2
const SINGLE_UNIT_CHANCE: float = 0.1


func getActiveEffectTiles(active_effect: ActiveEffectDatastore) -> ActiveEffectTiles:
	super(active_effect)
	if active_effect is ActiveAbilityDatastore and active_effect.name == "Palmist Prayer":
		var tiles: Array = getVisibleFieldCardsAllies().filter(func(x: CardGD): return x.isHealable())\
		.map(func(x: CardGD): return x.Tile)
		tiles.erase(Tile)
		return ActiveEffectTiles.new(tiles, tiles)
	return null
	
func onActiveEffectPre(_active_effect: ActiveEffectDatastore, PickedTile: TileGD, _active_effect_tiles: ActiveEffectTiles) -> void:
	onForceAction(ChangeTileRotationAction.new(self, Game.getRelativeTileRotation(Tile, PickedTile)))
	
func onActiveEffect(active_effect: ActiveEffectDatastore, PickedTile: TileGD, active_effect_tiles: ActiveEffectTiles) -> void:
	super(active_effect, PickedTile, active_effect_tiles)
	if active_effect is ActiveAbilityDatastore and active_effect.name == "Palmist Prayer":
		var heal_amount: int = 1 if !ascended else 2
		var allies: Array = getVisibleFieldCardsAllies()
		var actions: Array = [
			StatAction.new(allies.map(func(x: CardGD): return StatInfo.new(x, Game.Stats.HEALTH, heal_amount)) +
			allies.map(func(x: CardGD): return StatInfo.new(x, Game.Stats.ATTACK, -1, 1))),]
		
		onPushAction(actions)
		onAbility()

func getActiveEffectDisabled(active_effect: ActiveEffectDatastore) -> bool:
	if active_effect is ActiveAbilityDatastore and active_effect.name == "Palmist Prayer":
		return !inEnemyVision()
	return false
	
func onAIAbilityChecker(_active_effect: ActiveEffectDatastore, active_effect_tiles: ActiveEffectTiles, _dfl: DefaultFightLogic) -> TileGD:
	if active_effect_tiles.pickable_tiles.size() >= GUARANTEED_HEAL_UNIT_AMOUNT_AI:
		return active_effect_tiles.pickable_tiles.pick_random()
	elif active_effect_tiles.pickable_tiles.size() == 1 and Random.rollFloat(SINGLE_UNIT_CHANCE):
		return active_effect_tiles.pickable_tiles.pick_random()
	return null
