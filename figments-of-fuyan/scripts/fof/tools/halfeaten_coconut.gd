extends ToolGD

func onProcessAction(action: Action) -> void:
	super(action)
	
func onToolEquipped() -> void:
	super()
	
func onToolUnequipped() -> void:
	super()
	
func onToolHolderAwakened() -> void:
	super()
	
func onToolHolderDeath() -> void:
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
		onPushAction(HealAction.new(cards, 1))
		
# When possible
func onAIAbilityChecker(_active_effect: ActiveEffectDatastore, active_effect_tiles: ActiveEffectTiles, _DFL: DefaultFightLogic) -> TileGD:
	return active_effect_tiles.pickable_tiles.pick_random()
