extends CardGD

const SPECTATE_TELEPORTED_UNIT_DELAY: float = 1.5
func getActiveEffectDisabled(active_effect: ActiveEffectDatastore) -> bool:
	super(active_effect)
	if active_effect is ActiveAbilityDatastore and active_effect.name == "Cocus Pocus":
		return !isSpawnAvailable()
	return true
	
func getActiveEffectTiles(active_effect: ActiveEffectDatastore) -> ActiveEffectTiles:
	super(active_effect)
	if active_effect is ActiveAbilityDatastore and active_effect.name == "Cocus Pocus":
		var allies: Array = Game.getAllyUnits(team)
		allies.erase(self)
		
		var tiles: Array = Game.getAllyUnits(team).map(func(x: CardGD): return x.Tile)
		
		var pickable_allies: Array = allies.filter(func(x: CardGD): return x.isHealable())
		if !ascended and !pickable_allies.is_empty():
			pickable_allies.sort_custom(func(x: CardGD, y: CardGD): return (x.max_health - x.health) < (y.max_health - y.health))
			pickable_allies = [pickable_allies[0]]
			
		return ActiveEffectTiles.new(tiles, pickable_allies.map(func(x: CardGD): return x.Tile))
	return null
	
func onActiveEffectPre(_active_effect: ActiveEffectDatastore, PickedTile: TileGD, _active_effect_tiles: ActiveEffectTiles) -> void:
	onForceAction(ChangeTileRotationAction.new(self, Game.getRelativeTileRotation(Tile, PickedTile)))
	
func onActiveEffect(active_effect: ActiveEffectDatastore, PickedTile: TileGD, active_effect_tiles: ActiveEffectTiles) -> void:
	super(active_effect, PickedTile, active_effect_tiles)
	if active_effect is ActiveAbilityDatastore and active_effect.name == "Cocus Pocus":
		var Card: CardGD = Game.getFieldCard(PickedTile)
		var actions: Array = [CameraChangeAction.new(Card), OccupyAction.new(Card, getRandomSpawnTile())]
		
		var stat_action: StatAction = StatAction.new(StatInfo.new(Card, Game.Stats.HEALTH, 2))
		stat_action.setActionDelay(SPECTATE_TELEPORTED_UNIT_DELAY)
		actions.append(stat_action)
		actions.append(CameraChangeAction.new(self))
		onPushAction(actions)
		onAbility()
		
# Escapes injured units in combat, sorts by energy
func onAIAbilityChecker(_active_effect: ActiveEffectDatastore, active_effect_tiles: ActiveEffectTiles, _dfl: DefaultFightLogic) -> TileGD:
	var cards: Array = active_effect_tiles.pickable_tiles.map(func(x: TileGD): return Game.getFieldCard(x))
	cards = cards.filter(func(x: CardGD): return x.isInCombat() and x.getArchetype() not in [Game.Archetypes.WARDEN, Game.Archetypes.BRUTE])
	cards.sort_custom(func(x: CardGD, y: CardGD): return x.energy > y.energy)
	return cards[0].getTile() if !cards.is_empty() else null
		
func isSpawnAvailable() -> bool:
	var team_spawn: String = "Ally" if team == 0 else ("Enemy" if team == 1 else "Neutral")
	return get_tree().get_nodes_in_group(team_spawn + "SpawnsGD").any(func(x: SpawnGD): return !x.isSpawnOccupied())

func getRandomSpawnTile() -> TileGD:
	var team_spawn: String = "Ally" if team == 0 else ("Enemy" if team == 1 else "Neutral")
	return get_tree().get_nodes_in_group(team_spawn + "SpawnsGD")\
		.filter(func(x: SpawnGD): return !x.isSpawnOccupied())\
		.map(func(x: SpawnGD): return x.getTile())\
		.pick_random()
	
