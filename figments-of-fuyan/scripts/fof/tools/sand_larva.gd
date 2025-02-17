extends ToolGD

func onProcessAction(action: Action) -> void:
	super(action)
	
func onToolEquipped() -> void:
	super()
	
func onToolUnequipped() -> void:
	super()

func getActiveEffectTiles(active_effect: ActiveEffectDatastore) -> ActiveEffectTiles:
	super(active_effect)
	if active_effect.name == "Sandy Spy":
		return ActiveEffectTiles.new([Card.Tile], [Card.Tile])
	return null
	
func onActiveEffect(active_effect: ActiveEffectDatastore, PickedTile: TileGD, active_effect_tiles: ActiveEffectTiles) -> void:
	super(active_effect, PickedTile, active_effect_tiles)
	if active_effect.name == "Sandy Spy":
		var enemies: Array = Game.getEnemyUnits(Card.team).filter(func(x: CardGD): return !x.isRevealed(-1))
		if enemies.is_empty(): return
		
		var random_enemy: CardGD = enemies.pick_random()
		random_enemy.onCreateBaseStatusEffect(6)

# Use when possible
func onAIAbilityChecker(_active_effect: ActiveEffectDatastore, active_effect_tiles: ActiveEffectTiles, _DFL: DefaultFightLogic) -> TileGD:
	return active_effect_tiles.pickable_tiles[0]
