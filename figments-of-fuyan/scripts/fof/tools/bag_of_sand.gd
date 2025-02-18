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
	super(active_effect)
	if active_effect.name == info.name:
		var in_range_tiles: Array = Game.getAdjacentTiles(Card.Tile)
		return ActiveEffectTiles.new(in_range_tiles, in_range_tiles.filter(func(x: TileGD): return Game.getEnemyFieldCard(x, Card.team) != null))
	return null
	
func onActiveEffect(active_effect: ActiveEffectDatastore, PickedTile: TileGD, active_effect_tiles: ActiveEffectTiles) -> void:
	super(active_effect, PickedTile, active_effect_tiles)
	if active_effect.name == info.name:
		var EnemyCard: CardGD = Game.getFieldCard(PickedTile)
		EnemyCard.onCreateBaseStatusEffect(4)
		
		var actions: Array = [
			ChangeTileRotationAction.new(Card, Game.getRelativeTileRotation(Card.Tile, EnemyCard.Tile)),
			ChangeTileRotationAction.new(EnemyCard, Game.getRelativeTileRotation(EnemyCard.Tile, Card.Tile))]
		onPushAction(actions)

# If attacking someone with a non-lethal attack
func onAIAbilityChecker(_active_effect: ActiveEffectDatastore, active_effect_tiles: ActiveEffectTiles, DFL: DefaultFightLogic) -> TileGD:
	if DFL.getIsCardAttack() and !DFL.getIsKillGuaranteed():
		return active_effect_tiles.pickable_tiles.pick_random()
	return null
