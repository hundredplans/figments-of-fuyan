extends ToolGD

func onProcessAction(action: Action) -> void:
	super(action)
	
func onToolEquipped() -> void:
	pass
	
func onToolUnequipped() -> void:
	super()

func getActiveEffectTiles(active_effect: ActiveEffectDatastore) -> ActiveEffectTiles:
	if active_effect.name == "Half-eaten Coconut":
		var in_range_tiles: Array = Game.getAdjacentTiles(Card.Tile)
		return ActiveEffectTiles.new(in_range_tiles, in_range_tiles.filter(isPickable))
	return null
	
func isPickable(Tile: TileGD) -> bool:
	var FieldCard: CardGD = Game.getAllyFieldCard(Tile, Card.team)
	return FieldCard != null and (FieldCard.isHealable() or Card.isHealable())

func onActiveEffect(active_effect: ActiveEffectDatastore, PickedTile: TileGD, active_effect_tiles: ActiveEffectTiles) -> void:
	super(active_effect, PickedTile, active_effect_tiles)
	if active_effect.name == "Half-eaten Coconut":
		var cards: Array = [Game.getFieldCard(PickedTile)]
		if Card.isHealable(): cards.append(Card)
		
		var stat_infos: Array = cards.map(func(x: CardGD): return StatInfo.new(x, Game.Stats.HEALTH, 1))
		onPushAction(StatAction.new(stat_infos))
		
# When possible
func onAIAbilityChecker(_active_effect: ActiveEffectDatastore, active_effect_tiles: ActiveEffectTiles, _DFL: DefaultFightLogic) -> TileGD:
	return active_effect_tiles.pickable_tiles.pick_random()
