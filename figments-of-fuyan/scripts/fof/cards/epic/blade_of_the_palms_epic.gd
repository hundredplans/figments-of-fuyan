extends EpicCardGD

const BLIND_ID: int = 1
#region Defaults
func onSave() -> SavedDataBossCard:
	return super()

func onProcessAction(action: Action) -> void:
	super(action)
	
func getDescription() -> String:
	return super()
#endregion

#region Boss Intent
var use_teleport_passive: bool
func onUseBossIntent(enemies: Array, allies: Array, tiles: Array, use_type: UseType) -> void:
	var actions: Array = []
	if use_type == UseType.START: use_teleport_passive = false
	
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
		"Bat Attack":
			actions = onBatAttack(use_type)
	
	if !use_teleport_passive:
		use_teleport_passive = actions.any(func(x: Action):\
			return x is DamageAction and !x.Defenders.is_empty())
		#use_teleport_passive = actions.any(func(x: Action):\
			#return (x is DamageAction and !x.Defenders.is_empty()) or (x is AddStatusEffectAction and x.StatusEffect.info.id == 1))
			
	if use_type == UseType.END and use_teleport_passive:
		var teleport_action := getTeleportPassiveAction(enemies)
		if teleport_action != null:
			actions.append(teleport_action)
			
	onPushAction(BossIntentUsedAction.new(boss_intent, use_type, actions, enemies, allies))
	
const USE_ATTACK_PHASE_ONE_CHANCE: float = 0.75
func onChangeBossIntent(boss_intents: Array, enemies: Array, _allies: Array) -> BossIntent:
	match getPhase():
		1:
			if boss_intent.name == "Fan Blind":
				if Random.getBool(): return getBossIntentByName("Teleport Attack")
				else: return getBossIntentByName("Bat Attack")
			
			if enemies.is_empty(): # Out of combat
				boss_intents = onKeepByNames(boss_intents, ["Minifan Attack", "Reposition", "Teleport Attack"])
			else: # In Combat
				if Random.rollFloat(USE_ATTACK_PHASE_ONE_CHANCE) or !onHasNonAttackIntents(boss_intents):
					boss_intents = onKeepAttacks(boss_intents)
				elif onHasIntentName(boss_intents, "Fan Blind"): boss_intents = onKeepByName(boss_intents, "Fan Blind")
				else: boss_intents = onKeepNonAttacks(boss_intents)
				
			if boss_intents.is_empty(): return getBossIntentByName("Reposition")
			return boss_intents.pick_random()
	return null
	
func onCheckBossIntentCondition(conditional_boss_intent: BossIntent, enemies: Array, _allies: Array) -> bool:
	var condition_result: BossIntentConditionResult
	match conditional_boss_intent.name:
		"Fan Blind": condition_result = onFanBlindCondition(enemies)
		"Bat Attack": condition_result = onBatAttackCondition(enemies)
		_: condition_result = BossIntentConditionResult.new(true)
		
	boss_datastore.setConditionResult(condition_result, conditional_boss_intent.name)
	return condition_result.state
#endregion

#region Reposition
const REPOSITION_TELEPORT_DISTANCE: int = 4
const REPOSITION_TELEPORT_DELAY: float = 1.2
func onReposition(enemies: Array, tiles: Array, use_type: UseType) -> Array:
	if use_type != UseType.END:
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
				
		if ValidTeleportTile == null:
			for PotentialTeleportTile: TileGD in tiles:
				if Game.getCoordsDistance(coords, PotentialTeleportTile.getCoords()) < REPOSITION_TELEPORT_DISTANCE:
					ValidTeleportTile = PotentialTeleportTile
					break
		
		if ValidTeleportTile == null: return []
		
		var occupy_action := OccupyAction.new(self, ValidTeleportTile)
		occupy_action.setActionDelay(REPOSITION_TELEPORT_DELAY)
		var actions: Array = [occupy_action]
		return actions
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
		
		var actions: Array = [teleport_action,
			DamageAction.new(self, adjacent_enemies, attack, Game.DamageTypes.OTHER),
			DamageAction.new(self, double_adjacent_enemies, attack - 1, Game.DamageTypes.OTHER),
			DamageAction.new(self, triple_adjacent_enemies, attack - 2, Game.DamageTypes.OTHER)]
		
		var all_enemies: Array = adjacent_enemies + double_adjacent_enemies + triple_adjacent_enemies
		if !all_enemies.is_empty():
			actions.insert(1, ChangeTileRotationAction.new(self, Game.getRelativeTileRotation(TeleportTile, all_enemies.pick_random().getTile())))
		return actions
	return []
	
func onTeleportAttackSetIntents() -> BossTileIntents:
	var tile_intents: Array[TileIntentDatastore] = []
	var enemies: Array = getVisibleFieldCardsEnemies()
	
	enemies.sort_custom(func(x: CardGD, y: CardGD): return x.max_speed < y.max_speed)
	
	var TeleportTile: TileGD 
	if !enemies.is_empty(): TeleportTile = enemies[0].getTile()
	else: getVisibleTiles().pick_random()
	
	var teleport_coords: Vector4i = TeleportTile.getCoords()
	tile_intents.append(TileIntentDatastore.new(Game.TileIntents.DARK_RED, null, teleport_coords))
	
	var adjacent_coords: Array = Game.getAdjacentCoords(teleport_coords, 1)
	var double_adjacent_coords: Array = Game.getAdjacentCoords(teleport_coords, 2)
	var triple_adjacent_coords: Array = Game.getAdjacentCoords(teleport_coords, 3)
	
	for _coords: Vector4i in adjacent_coords:
		tile_intents.append(TileIntentDatastore.new(Game.TileIntents.RED, null, _coords))
		
	for _coords: Vector4i in double_adjacent_coords:
		tile_intents.append(TileIntentDatastore.new(Game.TileIntents.LIGHT_RED, null, _coords))
	
	for _coords: Vector4i in triple_adjacent_coords:
		tile_intents.append(TileIntentDatastore.new(Game.TileIntents.LIGHTER_RED, null, _coords))
	
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
		all_enemies = all_enemies.filter(func(x: CardGD): return x.getTile() in fan_attack_tiles)
		
		if all_enemies.size() == 1:
			actions.append(ChangeTileRotationAction.new(self, Game.getRelativeTileRotation(Tile, all_enemies[0].getTile())))
		
		actions.append(DamageAction.new(self, all_enemies, attack, Game.DamageTypes.OTHER))
	return actions
#endregion

#region Bat Attack
func onBatAttackCondition(enemies: Array) -> BossIntentConditionResultBatAttack:
	var condition_result := BossIntentConditionResultBatAttack.new(false)
	if boss_intent.name != "Fan Blind":
		var enemy_coords: Array = enemies.map(func(x: CardGD): return x.getCoords())
		var directions: Array = Game.getCubeDirectionsExtra()
		var direction_to_enemy_count: Dictionary[Vector4i, int] = {}
		var direction_to_bat_coords: Dictionary = {}
		for i: int in range(6):
			var direction: Vector4i = Game.getCubeDirectionExtra(i)
			var bat_coords: Dictionary[Vector4i, String] = getBatCoords(i)
			var bat_coords_keys: Array = bat_coords.keys().map(func(x: Vector4i): return x + coords)
			direction_to_enemy_count[direction] = enemy_coords.filter(func(x: Vector4i): return x in bat_coords_keys).size()
			direction_to_bat_coords[direction] = bat_coords
		
		directions.shuffle()
		directions.sort_custom(func(x: Vector4i, y: Vector4i): return direction_to_enemy_count[x] > direction_to_enemy_count[y])
		
		var prime_direction: Vector4i = directions[0]
		condition_result.setTileRotation(Game.getCubeDirectionsExtra().find(prime_direction))
		condition_result.setBatCoords(direction_to_bat_coords[prime_direction])
		condition_result.setState(direction_to_enemy_count[prime_direction] > 0)
	else:
		var bat_tile_rotation: int = boss_datastore.getConditionResult("Fan Blind").getTileRotation()
		condition_result.setTileRotation(bat_tile_rotation)
		condition_result.setBatCoords(getBatCoords(bat_tile_rotation))
		condition_result.setState(true)
	
	return condition_result

func onBatAttackSetIntents() -> BossTileIntents:
	var tile_intents: Array[TileIntentDatastore] = []
	
	var condition_results: BossIntentConditionResultBatAttack = boss_datastore.getConditionResult("Bat Attack")
	var bat_coords: Dictionary[Vector4i, String] = condition_results.getBatCoords()
	for bat_coord: Vector4i in bat_coords.keys():
		match bat_coords[bat_coord]:
			"Adjacent": tile_intents.append(TileIntentDatastore.new(Game.TileIntents.DARK_RED, OffsetDatastore.new(bat_coord), coords))
			"Bat": tile_intents.append(TileIntentDatastore.new(Game.TileIntents.RED, OffsetDatastore.new(bat_coord), coords))
			"Edge": tile_intents.append(TileIntentDatastore.new(Game.TileIntents.LIGHT_RED, OffsetDatastore.new(bat_coord), coords))
	
	return BossTileIntents.new(tile_intents, {})
	
func onBatAttack(use_type: UseType) -> Array:
	var actions: Array = []
	if use_type == UseType.START:
		var condition_result: BossIntentConditionResultBatAttack = boss_datastore.getConditionResult("Bat Attack")
		var bat_tile_rotation: int = condition_result.getTileRotation()
		var bat_coords: Dictionary[Vector4i, String] = condition_result.getBatCoords()
		var enemies: Array = Game.getEnemyUnits(team)
		var enemy_coords: Array = enemies.map(func(x: CardGD): return x.getCoords())
		
		var adjacent_damagables: Array = []
		var bat_damagables: Array = []
		var edge_damagables: Array = []
		
		for bat_coord: Vector4i in bat_coords.keys():
			var index: int = enemy_coords.find(bat_coord + coords)
			if index == -1: continue
			var EnemyCard: CardGD = enemies[index]
			
			match bat_coords[bat_coord]:
				"Adjacent":
					adjacent_damagables.append(EnemyCard)
				"Bat":
					bat_damagables.append(EnemyCard)
				"Edge":
					edge_damagables.append(EnemyCard)
		
		actions.append(ChangeTileRotationAction.new(self, bat_tile_rotation))
		actions.append(DamageAction.new(self, adjacent_damagables, attack, Game.DamageTypes.OTHER))
		actions.append(DamageAction.new(self, bat_damagables, attack - 1, Game.DamageTypes.OTHER))
		actions.append(DamageAction.new(self, edge_damagables, attack - 2, Game.DamageTypes.OTHER))
	return actions
	
func getBatCoords(_tile_rotation: int) -> Dictionary[Vector4i, String]:	
	var bat_coords: Dictionary[Vector4i, String] = {}
	
	var left_pyramid_coords: Array = Game.getInversePyramidCoords(Vector4i.ZERO, 6,  posmod(_tile_rotation - 1, 6), posmod(_tile_rotation - 2, 6), -1)
	var right_pyramid_coords: Array = Game.getInversePyramidCoords(Vector4i.ZERO, 6, (_tile_rotation + 1) % 6, (_tile_rotation + 2) % 6, 1)
	
	for _coords: Vector4i in Game.getAdjacentCoords(Vector4i.ZERO, 3):
		bat_coords[_coords] = "Edge"
	
	for _coords: Vector4i in Game.getAdjacentCoords(Vector4i.ZERO, 2) + left_pyramid_coords + right_pyramid_coords:
		bat_coords[_coords] = "Bat"
	
	for _coords: Vector4i in Game.getAdjacentCoords(Vector4i.ZERO, 1):
		bat_coords[_coords] = "Adjacent"
	
	return bat_coords
#endregion

#region Fan Blind
func onFanBlindCondition(enemies: Array) -> BossIntentConditionResultFanBlind:
	var condition_result := BossIntentConditionResultFanBlind.new(true)
	var directions: Array = Game.getCubeDirectionsExtra()
	var enemy_coords: Array = enemies.map(func(x: CardGD): return x.getCoords())
	
	var direction_to_enemy_count: Dictionary[Vector4i, int] = {}
	for i: int in range(6):
		var fan_coords: Array = Game.getFanCoords(coords, 5, i)
		var direction: Vector4i = directions[i]
		direction_to_enemy_count[direction] = enemy_coords.filter(func(x: Vector4i): return x in fan_coords).size()
		
	directions.shuffle()
	directions.sort_custom(func(x: Vector4i, y: Vector4i): return direction_to_enemy_count[x] > direction_to_enemy_count[y])

	var prime_direction: Vector4i = directions[0]
	condition_result.setState(direction_to_enemy_count[prime_direction] > 0)
	condition_result.setTileRotation(Game.getCubeDirectionsExtra().find(prime_direction))
	
	return condition_result

func onFanBlindSetIntents() -> BossTileIntents:
	var tile_intents: Array[TileIntentDatastore] = []
	var fan_coords: Array = Game.getFanCoords(Vector4i.ZERO, 5, boss_datastore.getConditionResult("Fan Blind").getTileRotation())
	fan_coords += Game.getAdjacentCoords(Vector4i.ZERO, 1).filter(func(x: Vector4i): return x not in fan_coords)
	
	for fan_coord: Vector4i in fan_coords:
		tile_intents.append(TileIntentDatastore.new(Game.TileIntents.PURPLE, OffsetDatastore.new(fan_coord), coords))
	
	return BossTileIntents.new(tile_intents, {})
	
func onFanBlind(use_type: UseType) -> Array:
	var actions: Array = []
	if use_type == UseType.START:
		var tile_rotation: int = boss_datastore.getConditionResult("Fan Blind").getTileRotation()
		var tiles: Array = Game.getFanTiles(Tile.getCoords(), 5, tile_rotation)
		var adjacent_tiles: Array = Game.getAdjacentTiles(Tile, 1).filter(func(x: TileGD): return x not in tiles)
		tiles += adjacent_tiles
		
		var enemies: Array = Game.getEnemyUnits(team)
		actions.append(ChangeTileRotationAction.new(self, tile_rotation))
		actions += onApplyBlind(enemies, tiles)
	return actions
#endregion

#region Teleport Passive
const PASSIVE_TELEPORT_DISTANCE: int = 2
func getTeleportPassiveAction(enemies: Array) -> TeleportAction:
	var tiles: Array = getVisibleTiles().filter(func(x: TileGD): return Game.getCoordsDistance(x.getCoords(), coords) == PASSIVE_TELEPORT_DISTANCE)
	tiles = getUnoccupiedTiles(tiles)
	tiles = getAllyVisionTiles(tiles)
	tiles = getDistantToEnemiesTiles(enemies, tiles)
	if tiles.is_empty(): return null
	return TeleportAction.new(self, tiles[0])
#endregion

#region Helper
func onApplyBlind(enemies: Array, tiles: Array, turns: int = 1) -> Array: # Returns blind actions
	return enemies.filter(func(x: CardGD): return x.getTile() in tiles).map(func(x: CardGD): return x.getBaseStatusEffectAction(BLIND_ID, turns))
#endregion
