extends CardGD

func getActiveEffectTiles(active_effect: ActiveEffectDatastore) -> ActiveEffectTiles:
	super(active_effect)
	if active_effect is ActiveAbilityDatastore and active_effect.name == "Palmist Prayer":
		var tiles: Array = [] if getVisibleFieldCardsEnemies().is_empty() else getVisibleFieldCardsAllies().map(func(x: CardGD): return x.Tile)
		tiles.erase(Tile)
		return ActiveEffectTiles.new(tiles, tiles)
	return null	
	
func onActiveEffectPre(active_effect: ActiveEffectDatastore, PickedTile: TileGD, active_effect_tiles: ActiveEffectTiles) -> void:
	force_action.emit(ChangeTileRotationAction.new(self, Game.getRelativeTileRotation(Tile, PickedTile)))
	
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
