extends CardGD

func getActiveEffectTiles(active_effect: ActiveEffectDatastore) -> ActiveEffectTiles:
	super(active_effect)
	if active_effect is ActiveAbilityDatastore and active_effect.name == "Helpful Helmet":
		var tiles: Array = Game.getAdjacentTiles(Tile)
		return ActiveEffectTiles.new(tiles, tiles.filter(func(x: TileGD): return Game.getAllyFieldCard(x, team)))
	return null
	
func onActiveEffect(active_effect: ActiveEffectDatastore, PickedTile: TileGD, active_effect_tiles: ActiveEffectTiles) -> void:
	super(active_effect, PickedTile, active_effect_tiles)
	if active_effect is ActiveAbilityDatastore and active_effect.name == "Helpful Helmet":
		var Card: CardGD = Game.getFieldCard(PickedTile)
		var actions: Array = [DestroyAction.new(self, self), ChangeTileRotationAction.new(self, Game.getRelativeTileRotation(Tile, Card.Tile))]
		
		var HelpfulHelmet: FieldEffectGD = SavedData.onLoadModel(SavedDataFieldEffect.new(5, true), Card)
		Card.onAddFieldEffect(HelpfulHelmet, Card)
		
		if ascended:
			actions.append(StatAction.new(StatInfo.new(Card, Game.Stats.MAX_HEALTH, 1)))
		
		setDeathAbility(true, false)
		onPushAction(actions)
