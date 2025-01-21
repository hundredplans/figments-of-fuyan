extends CardGD

const MINIMUM_HEALTH_TO_USE_HELPFUL_HELMET_AI: int = 3

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
		
# Use if a unit is adjacent with 3 or more health, if there's no units on board with 3 or more health use on whoever
func onAIAbilityChecker(_active_effect: ActiveEffectDatastore, active_effect_tiles: ActiveEffectTiles, _dfl: DefaultFightLogic) -> TileGD:
	if !isLevelVisible(): return null
	var card_to_health: Dictionary = {}
	for Tile in active_effect_tiles.pickable_tiles:
		var Card: CardGD = Game.getFieldCard(Tile)
		card_to_health[Card] = Card.health
		
	var max_ally_health_on_field: int = Game.getAllyUnits(team)\
		.filter(func(x: CardGD): return x != self)\
		.map(func(x: CardGD): return x.health).max()
		
	var max_health: int = card_to_health.values().max()
	if max_health >= MINIMUM_HEALTH_TO_USE_HELPFUL_HELMET_AI or max_ally_health_on_field < MINIMUM_HEALTH_TO_USE_HELPFUL_HELMET_AI:
		var cards: Array = card_to_health.keys()
		cards.shuffle()
		
		for Card in cards:
			if card_to_health[Card] == max_health:
				return Card.getTile()
	return null
