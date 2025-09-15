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

func getActiveEffectTiles() -> ActiveEffectTiles:
	var in_range_tiles: Array = Game.getAdjacentTiles(Card.Tile)
	return ActiveEffectTiles.new(in_range_tiles, in_range_tiles.filter(isPickable))
	
func isPickable(Tile: TileGD) -> bool:
	var FieldCard: CardGD = Game.getAllyFieldCard(Tile, Card.team)
	return FieldCard != null and (FieldCard.isHealable() or Card.isHealable())

func onActiveEffect(PickedTile: TileGD, active_effect_tiles: ActiveEffectTiles) -> void:
	var cards: Array = [Game.getFieldCard(PickedTile)]
	if Card.isHealable(): cards.append(Card)
	onPushAction(HealAction.new(cards.map(func(x: CardGD): return HealDatastore.new(x, 1))))
		
# When possible
func onAIAbilityChecker(active_effect_tiles: ActiveEffectTiles, _DFL: DefaultFightLogic, type := Game.AbilityAI.NULL) -> TileGD:
	return active_effect_tiles.pickable_tiles.pick_random()
