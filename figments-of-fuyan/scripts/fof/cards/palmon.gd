extends CardGD

func getActiveEffectTiles(active_effect: ActiveEffectDatastore) -> ActiveEffectTiles:
	super(active_effect)
	if active_effect is ActiveAbilityDatastore and active_effect.name == "Treeleaf Remedy":
		var tiles: Array = Game.getAdjacentOrCloserTiles(Tile, 2)
		return ActiveEffectTiles.new(tiles, tiles.filter(func(x: TileGD): return Game.getAllyFieldCard(x, team) != null))
	return null
	
func onActiveEffect(active_effect: ActiveEffectDatastore, PickedTile: TileGD, active_effect_tiles: ActiveEffectTiles) -> void:
	super(active_effect, PickedTile, active_effect_tiles)
	if active_effect is ActiveAbilityDatastore and active_effect.name == "Treeleaf Remedy":
		var Card: CardGD = Game.getFieldCard(PickedTile)
		var attack_gain: int = 1 if !ascended else 2
		var actions: Array = [
			StatAction.new(StatInfo.new(Card, Game.Stats.ATTACK, attack_gain, 1)),
			DelayedHealAction.new(HealDatastore.new(Card, 1, 1)),
			ChangeTileRotationAction.new(self, Game.getRelativeTileRotation(Tile, Card.Tile))]
		
		onPushAction(actions)
		onAbility()
		
# If the unit is in combat, is healable, then sorted by how low the attack is
func onAIAbilityChecker(_active_effect: ActiveEffectDatastore, active_effect_tiles: ActiveEffectTiles, _dfl: DefaultFightLogic) -> TileGD:
	var cards: Array = active_effect_tiles.pickable_tiles.map(func(x: TileGD): return Game.getFieldCard(x))
	
	cards = cards.filter(func(x: CardGD): return x.isHealable() and x.isInCombat())
	cards.shuffle()
	cards.sort_custom(func(x: CardGD, y: CardGD): return x.attack > y.attack)
	
	if cards.is_empty(): return null
	return cards[0].getTile()
	
func getDescription() -> String:
	var active_effect: ActiveEffectDatastore = getActiveEffectByName("Treeleaf Remedy")
	if active_effect != null:
		return Helper.getDescription(super(), [active_effect.charges])
	return super()
