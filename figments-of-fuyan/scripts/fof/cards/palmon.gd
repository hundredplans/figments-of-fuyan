extends CardGD

func getActiveEffectTiles(active_effect: ActiveEffectDatastore) -> ActiveEffectTiles:
	super(active_effect)
	if active_effect is ActiveAbilityDatastore and active_effect.name == "Treeleaf Remedy":
		var tiles: Array = getVisibleTiles()
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
