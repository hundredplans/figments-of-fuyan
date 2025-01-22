extends CardGD

func getActiveEffectTiles(active_effect: ActiveEffectDatastore) -> ActiveEffectTiles:
	super(active_effect)
	if active_effect is ActiveAbilityDatastore and active_effect.name == "Treeleaf Remedy":
		var tiles: Array = getVisibleTiles()
		tiles.erase(Tile)
		return ActiveEffectTiles.new(tiles, tiles.filter(func(x: TileGD): return Game.getAllyFieldCard(x, team) != null))
	return null
	
func onActiveEffect(active_effect: ActiveEffectDatastore, PickedTile: TileGD, active_effect_tiles: ActiveEffectTiles) -> void:
	super(active_effect, PickedTile, active_effect_tiles)
	if active_effect is ActiveAbilityDatastore and active_effect.name == "Treeleaf Remedy":
		var Card: CardGD = Game.getFieldCard(PickedTile)
		var attack_gain: int = 1 if !ascended else 2
		var actions: Array = [
			StatAction.new(StatInfo.new(Card, Game.Stats.ATTACK, attack_gain, 1)),
			DelayedStatAction.new(StatInfo.new(Card, Game.Stats.HEALTH, 1, 1)),
			ChangeTileRotationAction.new(self, Game.getRelativeTileRotation(Tile, Card.Tile))]
		
		onPushAction(actions)
		onAbility()
		
# If the attack makes a difference on a unit which didn't use it's turn yet or 30% chance to just heal
func onAIAbilityChecker(_active_effect: ActiveEffectDatastore, active_effect_tiles: ActiveEffectTiles, _dfl: DefaultFightLogic) -> TileGD:
	var cards: Array = active_effect_tiles.pickable_tiles.map(func(x: TileGD): return Game.getFieldCard(x))
	var cards_turn_used: Array = cards.filter(func(x: CardGD): return x.turn_state == Game.TurnStates.INACTIVE)
	var cards_turn
	
	return null
