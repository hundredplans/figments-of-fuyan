extends EpicCardGD

const BLIND_ID: int = 1
#region Defaults
func onSave() -> SavedDataBossCard:
	ability_save["reposition_teleports_used"] = reposition_teleports_used
	return super()

func onProcessAction(action: Action) -> void:
	super(action)
	
func getDescription() -> String:
	return super()
#endregion

#region Boss Intent
func onUseBossIntent(enemies: Array, allies: Array, tiles: Array, use_type: UseType) -> void:
	var actions: Array = []
	match boss_intent.name:
		"Reposition":
			actions = onReposition(enemies, tiles, use_type)
		"Teleport Attack":
			actions = onTeleportAttack(use_type)
		"Petal Attack":
			actions = onPetalAttack(use_type)
		"Minifan Attack":
			actions = onMinifanAttack(enemies, tiles, use_type)
		"Fan Blind":
			actions = onFanBlind(use_type)
			
	onPushAction(BossIntentUsedAction.new(boss_intent, use_type, actions, enemies, allies))
	
const USE_ATTACK_PHASE_ONE_CHANCE: float = 0.75
func onChangeBossIntent(boss_intents: Array, enemies: Array, _allies: Array) -> BossIntent:
	match getPhase():
		1:
			if enemies.is_empty(): # Out of combat
				boss_intents = onKeepByNames(boss_intents, ["Minifan Attack", "Reposition", "Teleport Attack"])
			else: # In Combat
				if Random.rollFloat(USE_ATTACK_PHASE_ONE_CHANCE) or !onHasNonAttackIntents(boss_intents):
					boss_intents = onKeepAttacks(boss_intents)
				elif onHasIntentName(boss_intents, "Fan Blind"): boss_intents = onKeepByName(boss_intents, "Fan Blind")
				else: boss_intents = onKeepNonAttacks(boss_intents)
				
			return boss_intents.pick_random()
	return null
	
func onCheckBossIntentCondition(conditional_boss_intent: BossIntent, _enemies: Array, _allies: Array) -> bool:
	var condition_result: BossIntentConditionResult
	match conditional_boss_intent.name:
		_: condition_result = BossIntentConditionResult.new(true)
		
	boss_datastore.setConditionResult(condition_result, conditional_boss_intent.name)
	return condition_result.state
#endregion

#region Reposition
const PHASE_ONE_REPOSITION_TELEPORT_AMOUNT: int = 2
const REPOSITION_TELEPORT_DISTANCE: int = 2
const REPOSITION_TELEPORT_DELAY: float = 1.2
var reposition_teleports_used: int = 0
func onReposition(enemies: Array, tiles: Array, use_type: UseType) -> Array:
	if use_type != UseType.END and reposition_teleports_used < PHASE_ONE_REPOSITION_TELEPORT_AMOUNT:
		tiles = getVisibleTiles()
		tiles = getUnoccupiedTiles(tiles)
		tiles = getAllyVisionTiles(tiles)
		tiles = getDistantToEnemiesTiles(enemies, tiles)
		if tiles.is_empty(): return []
		
		var ValidTeleportTile: TileGD
		for PotentialTeleportTile: TileGD in tiles:
			if Game.getCoordsDistance(coords, PotentialTeleportTile.getCoords()) == REPOSITION_TELEPORT_DISTANCE:
				ValidTeleportTile = PotentialTeleportTile
				break
		
		if ValidTeleportTile == null: return []
		
		var occupy_action := OccupyAction.new(self, ValidTeleportTile)
		occupy_action.setActionDelay(REPOSITION_TELEPORT_DELAY)
		var actions: Array = [OccupyAction.new(self, ValidTeleportTile)]
		
		reposition_teleports_used += 1
		if reposition_teleports_used < PHASE_ONE_REPOSITION_TELEPORT_AMOUNT:
			var SecondTeleportTile: TileGD
			for PotentialTeleportTile: TileGD in tiles:
				if Game.getCoordsDistance(coords, PotentialTeleportTile.getCoords()) == (REPOSITION_TELEPORT_DISTANCE * 2):
					SecondTeleportTile = PotentialTeleportTile
					break
			
			var second_occupy_action := OccupyAction.new(self, SecondTeleportTile)
			second_occupy_action.setActionDelay(REPOSITION_TELEPORT_DELAY)
			
			if SecondTeleportTile == null: return []
			actions.append(second_occupy_action)
		return actions
	reposition_teleports_used = 0
	return []
	
func onRepositionSetIntents() -> BossTileIntents: return BossTileIntents.new()
#endregion

#region Teleport Attack
func onTeleportAttack(use_type: UseType) -> Array:
	if use_type == UseType.START:
		var TeleportTile: TileGD = boss_datastore.getTileResults().keys()[0]
		var teleport_action := TeleportAction.new(self, TeleportTile)
		
		var enemies: Array = Game.getEnemyUnits(team)
		var enemy_tiles: Array = enemies.map(func(x: CardGD): return x.getTile())
		
		var adjacent_tiles: Array = Game.getAdjacentTiles(TeleportTile, 1).filter(func(x: TileGD): return x in enemy_tiles)
		var double_adjacent_tiles: Array = Game.getAdjacentTiles(TeleportTile, 2).filter(func(x: TileGD): return x in enemy_tiles)
		var triple_adjacent_tiles: Array = Game.getAdjacentTiles(TeleportTile, 3).filter(func(x: TileGD): return x in enemy_tiles)
		
		var adjacent_enemies: Array = adjacent_tiles.map(func(x: TileGD): return enemies[enemy_tiles.find(x)])
		var double_adjacent_enemies: Array = double_adjacent_tiles.map(func(x: TileGD): return enemies[enemy_tiles.find(x)])
		var triple_adjacent_enemies: Array = triple_adjacent_tiles.map(func(x: TileGD): return enemies[enemy_tiles.find(x)])
		
		var actions: Array = [ClearTileIntentsAction.new(), teleport_action,
			DamageAction.new(self, adjacent_enemies, attack, Game.DamageTypes.OTHER),
			DamageAction.new(self, double_adjacent_enemies, attack - 1, Game.DamageTypes.OTHER),
			DamageAction.new(self, triple_adjacent_enemies, attack - 2, Game.DamageTypes.OTHER)]
		return actions
	return []
	
func onTeleportAttackSetIntents() -> BossTileIntents:
	var tile_intents: Array[TileIntentDatastore] = []
	var enemies: Array = getVisibleFieldCardsEnemies()
	
	enemies.sort_custom(func(x: CardGD, y: CardGD): return x.max_speed < y.max_speed)
	
	var TeleportTile: TileGD = enemies[0].getTile()
	var teleport_coords: Vector4i = TeleportTile.getCoords()
	var relative: Vector4i = teleport_coords - coords
	tile_intents.append(TileIntentDatastore.new(Game.TileIntents.DARK_RED, OffsetDatastore.new(relative - teleport_coords), coords))
	
	var adjacent_coords: Array = Game.getAdjacentCoords(coords, 1)
	var double_adjacent_coords: Array = Game.getAdjacentCoords(coords, 2)
	var triple_adjacent_coords: Array = Game.getAdjacentCoords(coords, 3)
	
	for _coords: Vector4i in adjacent_coords:
		tile_intents.append(TileIntentDatastore.new(Game.TileIntents.RED, OffsetDatastore.new(relative - _coords), coords))
		
	for _coords: Vector4i in double_adjacent_coords:
		tile_intents.append(TileIntentDatastore.new(Game.TileIntents.LIGHT_RED, OffsetDatastore.new(relative - _coords), coords))
	
	for _coords: Vector4i in triple_adjacent_coords:
		tile_intents.append(TileIntentDatastore.new(Game.TileIntents.LIGHTER_RED, OffsetDatastore.new(relative - _coords), coords))
	
	return BossTileIntents.new(tile_intents, {TeleportTile: "TeleportTile"})
#endregion

#region Petal Attack
func onPetalAttackSetIntents() -> BossTileIntents:
	var tile_intents: Array[TileIntentDatastore] = []
	var tile_results: Dictionary[TileGD, String] = {}
	var triple_adjacent_diagonal_tiles: Array = []
	var all_diagonal_coords: Array = []
	
	for direction: Vector4i in Game.getCubeDirectionsExtra():
		for i in range(1, 4):
			var direction_coords := direction * i
			all_diagonal_coords.append(direction_coords)
			
			tile_intents.append(TileIntentDatastore.new(Game.TileIntents.PURPLE, OffsetDatastore.new(direction_coords), coords))
			direction_coords += coords
			var DiagonalTile: TileGD = Game.getTile(direction_coords)
			if DiagonalTile != null:
				triple_adjacent_diagonal_tiles.append(DiagonalTile)
				tile_results[DiagonalTile] = "DiagonalTile"
	
	var triple_adjacent_coords: Array = Game.getAdjacentOrCloserCoords(Vector4i.ZERO, 3).filter(func(x: Vector4i): return x not in all_diagonal_coords)
	for _coords: Vector4i in triple_adjacent_coords:
		tile_intents.append(TileIntentDatastore.new(Game.TileIntents.RED, OffsetDatastore.new(_coords), coords))
	
	return BossTileIntents.new(tile_intents, tile_results)
		
func onPetalAttack(use_type: UseType) -> Array:
	var actions: Array = []
	if use_type == UseType.START:
		var diagonal_tiles: Array = boss_datastore.getTileResults().keys()
		var triple_adjacent_tiles: Array = Game.getAdjacentOrCloserTiles(Tile, 3).filter(func(x: TileGD): return x not in diagonal_tiles)
		
		var enemies: Array = Game.getEnemyUnits(team)
		actions.append(DamageAction.new(self, enemies.filter(func(x: CardGD): return x.getTile() in triple_adjacent_tiles), attack, Game.DamageTypes.OTHER))
		actions += onApplyBlind(enemies, diagonal_tiles)
	return actions
#endregion

#region Minifan Attack
func onMinifanAttackSetIntents() -> BossTileIntents:
	var tile_intents: Array[TileIntentDatastore] = []
	var fan_coords: Array = Game.getFanCoords(Vector4i.ZERO, 2)
	
	for fan_coord: Vector4i in fan_coords:
		tile_intents.append(TileIntentDatastore.new(Game.TileIntents.RED, OffsetDatastore.new(fan_coord, true, tile_rotation), coords))
	
	return BossTileIntents.new(tile_intents, {})
	
func onMinifanAttack(enemies: Array, tiles: Array, use_type: UseType) -> Array:
	var actions: Array = []
	if use_type != UseType.END and !tiles.is_empty():
		tiles = getUnoccupiedTiles(tiles)
		tiles = getAllyVisionTiles(tiles)
		tiles = getCloseToEnemiesTiles(enemies, tiles)
		
		var BestTile: TileGD = tiles[0]
		actions.append(MovementAction.new(self, BestTile.getMovementPathTiles()))
	
	if use_type == UseType.END:
		var all_enemies: Array = Game.getEnemyUnits(team)
		var tile_rotation_to_enemy_count: Dictionary[int, int] = {}
		for new_tile_rotation in range(6):
			var fan_tiles: Array = Game.getFanTiles(Tile.getCoords(), 2, new_tile_rotation)
			tile_rotation_to_enemy_count[new_tile_rotation] = all_enemies.filter(func(x: CardGD): return x.getTile() in fan_tiles).size()
		
		var tile_rotations: Array = tile_rotation_to_enemy_count.keys()
		tile_rotations.sort_custom(func(x: int, y: int): return tile_rotation_to_enemy_count[x] > tile_rotation_to_enemy_count[y])
		
		var chosen_tile_rotation: int = tile_rotations[0]
		if tile_rotation_to_enemy_count[chosen_tile_rotation] > 0:
			actions.append(ChangeTileRotationAction.new(self, chosen_tile_rotation))
		else: chosen_tile_rotation = tile_rotation
		
		var fan_attack_tiles: Array = Game.getFanTiles(Tile.getCoords(), 2, chosen_tile_rotation)
		actions.append(DamageAction.new(self, all_enemies.filter(func(x: CardGD): return x.getTile() in fan_attack_tiles), attack, Game.DamageTypes.OTHER))
	return actions
#endregion

#region Bat Attack
func onBatAttackSetIntents() -> BossTileIntents:
	var tile_intents: Array[TileIntentDatastore] = []
	var adjacent_coords: Array = Game.getAdjacentOrCloserCoords(Vector4i.ZERO, 1)
	
	var inverse_pyramid_coords: Array = Game.getInversePyramidCoords(Vector4i.ZERO, 6, (tile_rotation - 1) % 6, (tile_rotation - 2) % 6)
	inverse_pyramid_coords += Game.getInversePyramidCoords(Vector4i.ZERO, 6, (tile_rotation + 1) % 6, (tile_rotation + 2) % 6)
	inverse_pyramid_coords = inverse_pyramid_coords.filter(func(x: Vector4i): return x not in adjacent_coords)
	
	for _coords: Vector4i in adjacent_coords:
		tile_intents.append(TileIntentDatastore.new(Game.TileIntents.RED, OffsetDatastore.new(_coords), coords))
		
	for _coords: Vector4i in inverse_pyramid_coords:
		tile_intents.append(TileIntentDatastore.new(Game.TileIntents.LIGHT_RED, OffsetDatastore.new(_coords), coords))
	
	return BossTileIntents.new(tile_intents, {})
	
func onBatAttack(use_type: UseType) -> Array:
	var actions: Array = []
	if use_type == UseType.START:
		pass
	return actions
#endregion

#region Fan Blind
func onFanBlindSetIntents() -> BossTileIntents:
	var tile_intents: Array[TileIntentDatastore] = []
	var fan_coords: Array = Game.getFanCoords(Vector4i.ZERO, 5)
	fan_coords +=  Game.getAdjacentCoords(Vector4i.ZERO, 1).filter(func(x: Vector4i): return x not in fan_coords)
	
	for fan_coord: Vector4i in fan_coords:
		tile_intents.append(TileIntentDatastore.new(Game.TileIntents.PURPLE, OffsetDatastore.new(fan_coord, true, tile_rotation), coords))
	
	return BossTileIntents.new(tile_intents, {})
	
func onFanBlind(use_type: UseType) -> Array:
	var actions: Array = []
	if use_type == UseType.START:
		var tiles: Array = Game.getFanTiles(Tile.getCoords(), 5, tile_rotation)
		var adjacent_tiles: Array = Game.getAdjacentTiles(Tile, 1).filter(func(x: TileGD): return x not in tiles)
		tiles += adjacent_tiles
		
		var enemies: Array = Game.getEnemyUnits(team)
		actions += onApplyBlind(enemies, tiles)
	return actions
#endregion

#region Helper
func onApplyBlind(enemies: Array, tiles: Array, turns: int = 1) -> Array: # Returns blind actions
	return enemies.filter(func(x: CardGD): return x.getTile() in tiles).map(func(x: CardGD): return x.getBaseStatusEffectAction(BLIND_ID, turns))
#endregion
