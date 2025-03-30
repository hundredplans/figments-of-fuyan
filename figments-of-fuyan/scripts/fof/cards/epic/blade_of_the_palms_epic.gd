extends EpicCardGD

const TELEPORT_ENTER_ACTION_DELAY: float = 1.2
const FIRST_PHASE_CHANGE_HEALTH: int = 14
const SECOND_PHASE_CHANGE_HEALTH: int = 7

const FATIGUE_ID: int = 3
const BLIND_ID: int = 1
const REVEALED_ID: int = 6
const CLONE_ID: int = 78

const PEDESTAL_TILE_COORDS := Vector4i(6, -12, 6, 8)

#region Defaults
func onSave() -> SavedDataBossCard:
	return super()

func onProcessAction(action: Action) -> void:
	super(action)
	if action.post:
		if action is StatAction and action.hasCard(self) and\
			((health <= SECOND_PHASE_CHANGE_HEALTH and getPhase() < 3) or (health <= FIRST_PHASE_CHANGE_HEALTH and getPhase() < 2)):
			onPushAction(ChangeBossPhaseAction.new())
		elif action is DeathAction and getPhase() == 3 and action.Defender.isEnemy(team) and action.owner == self:
			onPushAction(HealAction.new(HealDatastore.new(self, 1)))
		elif action is DeathAction and action.Defender.info.id == CLONE_ID and action.Defender.is_clone_summon:
			onCloneSummonDeathRevealIntent()
		elif action is DamageAction and self in action.Defenders:
			onHurtRevealIntentIfCloneSummon()
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
		"Double Teleport Attack":
			actions = onDoubleTeleportAttack(use_type)
		"Mist Attack":
			actions = onMistAttack(use_type)
		"Clone Phase Change":
			actions = onClonePhaseChange(use_type)
		"Dodge Phase Change":
			actions = onDodgePhaseChange(use_type)
		"Clone Summon":
			actions = onCloneSummon(use_type)
		"Hammer Attack":
			actions = await onHammerAttack(use_type)
		"Clone Minifan Attack":
			actions = onCloneMinifanAttack(enemies, tiles, use_type)
	
	if !use_teleport_passive:
		use_teleport_passive = actions.any(func(x: Action):\
			return x is DamageAction and !x.Defenders.is_empty())
		#use_teleport_passive = actions.any(func(x: Action):\
			#return (x is DamageAction and !x.Defenders.is_empty()) or (x is AddStatusEffectAction and x.StatusEffect.info.id == 1))
			
	if use_type == UseType.END and use_teleport_passive:
		var teleport_actions: Array = getTeleportPassiveAction(enemies)
		if !teleport_actions.is_empty():
			actions += teleport_actions
			
	onPushAction(BossIntentUsedAction.new(boss_intent, use_type, actions, enemies, allies))
	
const USE_ATTACK_PHASE_ONE_CHANCE: float = 0.75
func onChangeBossIntent(boss_intents: Array, enemies: Array, _allies: Array) -> BossIntent:
	var phase: int = getPhase()
	if boss_intent.name in  ["Clone Phase Change", "Dodge Phase Change"]:
		return getBossIntentByName("Double Teleport Attack")
	
	if phase in [2, 3]: 
		boss_intents = boss_intents.filter(func(x: BossIntent): return x.name not in ["Clone Phase Change", "Dodge Phase Change"])
		
	if boss_intent.name == "Fan Blind":
		if Random.getBool(): return getBossIntentByName("Teleport Attack" if phase == 1 else "Double Teleport Attack")
		else: return getBossIntentByName("Bat Attack")
	
	if enemies.is_empty(): # Out of combat
		boss_intents = onKeepByNames(boss_intents, ["Minifan Attack", "Reposition", "Teleport Attack", "Mist Attack", "Double Teleport Attack"])
	else: # In Combat
		if Random.rollFloat(USE_ATTACK_PHASE_ONE_CHANCE) or !onHasNonAttackIntents(boss_intents):
			boss_intents = onKeepAttacks(boss_intents)
		elif onHasIntentName(boss_intents, "Fan Blind"): boss_intents = onKeepByName(boss_intents, "Fan Blind")
		else: boss_intents = onKeepNonAttacks(boss_intents)
		
	if boss_intents.is_empty(): return getBossIntentByName("Reposition")
	return boss_intents.pick_random()
	
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
const TELEPORT_EXIT_ACTION_DELAY: float = 1.2
const REPOSITION_TELEPORT_DISTANCE: int = 4
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
		
		var teleport_enter := AnimationAction.new(self, "TeleportEnter")
		teleport_enter.setActionDelay(TELEPORT_ENTER_ACTION_DELAY)
		
		var teleport_exit := AnimationAction.new(self, "TeleportExit")
		teleport_exit.setActionDelay(TELEPORT_EXIT_ACTION_DELAY)

		var actions: Array = [teleport_enter, OccupyAction.new(self, ValidTeleportTile), teleport_exit]
		return actions
	return []
	
func onRepositionSetIntents() -> BossTileIntents: return BossTileIntents.new()
#endregion

#region Teleport Attack
const TELEPORT_ATTACK_ACTION_DELAY: float = 2.5
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
		
		var teleport_enter := AnimationAction.new(self, "TeleportEnter")
		teleport_enter.setActionDelay(TELEPORT_ENTER_ACTION_DELAY)
		
		var teleport_attack := AnimationAction.new(self, "TeleportAttack")
		teleport_attack.setActionDelay(TELEPORT_ATTACK_ACTION_DELAY)
		
		var actions: Array = [teleport_enter, teleport_action, teleport_attack,
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
const PETAL_ATTACK_ANIMATION_DELAY: float = 2.0
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
		
		var animation_action := AnimationAction.new(self, "PetalAttack")
		animation_action.setActionDelay(PETAL_ATTACK_ANIMATION_DELAY)
		actions.append(animation_action)
		
		actions.append(DamageAction.new(self, enemies.filter(func(x: CardGD): return x.getTile() in triple_adjacent_tiles), attack, Game.DamageTypes.OTHER))
		actions += onApplyBlind(enemies, diagonal_tiles)
	return actions
#endregion

#region Minifan Attack
const MINIFAN_ATTACK_ACTION_DELAY: float = 2.0
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
		
		var animation_action := AnimationAction.new(self, "MiniFan")
		animation_action.setActionDelay(MINIFAN_ATTACK_ACTION_DELAY)
		actions.append(animation_action)
		
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
	
const BAT_ATTACK_ANIMATION_DELAY: float = 2.5
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
		
		var animation_action := AnimationAction.new(self, "BatAttack")
		animation_action.setActionDelay(BAT_ATTACK_ANIMATION_DELAY)
		actions.append(animation_action)
		
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
const FAN_BLIND_ANIMATION_DELAY: float = 2.0
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
		var _tile_rotation: int = boss_datastore.getConditionResult("Fan Blind").getTileRotation()
		var tiles: Array = Game.getFanTiles(Tile.getCoords(), 5, _tile_rotation)
		var adjacent_tiles: Array = Game.getAdjacentTiles(Tile, 1).filter(func(x: TileGD): return x not in tiles)
		tiles += adjacent_tiles
		
		var enemies: Array = Game.getEnemyUnits(team)
		actions.append(ChangeTileRotationAction.new(self, _tile_rotation))
		
		var animation_action := AnimationAction.new(self, "FanBlind")
		animation_action.setActionDelay(FAN_BLIND_ANIMATION_DELAY)
		actions.append(animation_action)
		
		actions += onApplyBlind(enemies, tiles)
	return actions
#endregion

#region Teleport Passive
const PASSIVE_TELEPORT_DISTANCE: int = 2
func getTeleportPassiveAction(enemies: Array) -> Array:
	var tiles: Array = getVisibleTiles().filter(func(x: TileGD): return Game.getCoordsDistance(x.getCoords(), coords) == PASSIVE_TELEPORT_DISTANCE)
	tiles = getUnoccupiedTiles(tiles)
	tiles = getAllyVisionTiles(tiles)
	tiles = getDistantToEnemiesTiles(enemies, tiles)
	if tiles.is_empty(): return []
	
	var teleport_enter := AnimationAction.new(self, "TeleportEnter")
	teleport_enter.setActionDelay(TELEPORT_ENTER_ACTION_DELAY)
		
	var teleport_exit := AnimationAction.new(self, "TeleportExit")
	teleport_exit.setActionDelay(TELEPORT_EXIT_ACTION_DELAY)
	
	return [teleport_enter, TeleportAction.new(self, tiles[0]), teleport_exit]
#endregion

#region Double Teleport Attack
func onDoubleTeleportAttackSetIntents() -> BossTileIntents:
	var tile_intents: Array[TileIntentDatastore] = []
	var enemies: Array = getVisibleFieldCardsEnemies()
	
	if enemies.is_empty():
		enemies = Game.getEnemyUnits(team)
	
	enemies.shuffle()
	enemies.sort_custom(func(x: CardGD, y: CardGD): return x.max_speed < y.max_speed)
	
	var visible_tiles: Array = getVisibleTiles()
	visible_tiles = getAllyVisionTiles(visible_tiles)
	visible_tiles.shuffle()
	
	var teleport_tiles: Array = []
	for __: int in range(2):
		if !enemies.is_empty():
			var TeleportTile: TileGD = enemies.pop_front().getTile()
			teleport_tiles.append(TeleportTile)
			visible_tiles.erase(TeleportTile)
			continue
	
	var coords_to_distance: Dictionary[Vector4i, int] = {}
	var tile_results: Dictionary[TileGD, String] = {}
	
	for distance: int in range(3, 0, -1): # Goes from furthest to closest, since closest take priority
		for i in range(teleport_tiles.size()):
			var TeleportTile: TileGD = teleport_tiles[i]
			var teleport_coords: Vector4i = TeleportTile.getCoords()
			for coord: Vector4i in Game.getAdjacentCoords(teleport_coords, distance):
				coords_to_distance[coord] = distance
				
				var CoordTile: TileGD = Game.getTile(coord)
				if CoordTile == null: continue
				tile_results[CoordTile] = str(distance) + ":" + str(i)

	for i: int in range(teleport_tiles.size()):
		var TeleportTile: TileGD = teleport_tiles[i]
		coords_to_distance[TeleportTile.getCoords()] = 0
		tile_results[TeleportTile] = str(0) + ":" + str(i)
	
	for coord: Vector4i in coords_to_distance:
		var distance: int = coords_to_distance[coord]
		var tile_intent: Game.TileIntents
		match distance:
			3: tile_intent = Game.TileIntents.LIGHTER_RED
			2: tile_intent = Game.TileIntents.LIGHT_RED
			1: tile_intent = Game.TileIntents.RED
			0: tile_intent = Game.TileIntents.DARK_RED
		tile_intents.append(TileIntentDatastore.new(tile_intent, null, coord))
	
	return BossTileIntents.new(tile_intents, tile_results)
	
func onDoubleTeleportAttack(use_type: UseType) -> Array:
	if use_type == UseType.START:
		onResetIdleModifier() # For hammer idle
		var actions: Array = []
		var tile_results: Dictionary[TileGD, String] = boss_datastore.getTileResults()
		
		var enemies: Array = Game.getEnemyUnits(team)
		var enemy_tiles: Array = enemies.map(func(x: CardGD): return x.getTile())
		
		var teleport_tiles: Array = []
		teleport_tiles.shuffle()
		
		var teleport_tile_radius: Array = [[], []]
		for RadiusTile: TileGD in tile_results.keys():
			teleport_tile_radius[int(tile_results[RadiusTile][tile_results[RadiusTile].length() - 1])].append(RadiusTile)
			
		for i in range(teleport_tile_radius.size()):
			var radius_array: Array = teleport_tile_radius[i]
			var adjacent_enemies: Array = []
			var double_adjacent_enemies: Array = []
			var triple_adjacent_enemies: Array = []
			var TeleportTile: TileGD
			for RadiusTile: TileGD in radius_array:
				if int(tile_results[RadiusTile][0]) == 0:
					TeleportTile = RadiusTile
					continue
				
				var index: int = enemy_tiles.find(RadiusTile)
				if index == -1: continue
				
				var EnemyCard: CardGD = enemies[index]
				match int(tile_results[RadiusTile][0]):
					1: adjacent_enemies.append(EnemyCard)
					2: double_adjacent_enemies.append(EnemyCard)
					3: triple_adjacent_enemies.append(EnemyCard)
		
			var teleport_enter := AnimationAction.new(self, "TeleportEnter")
			teleport_enter.setActionDelay(TELEPORT_ENTER_ACTION_DELAY)
		
			var teleport_attack := AnimationAction.new(self, "TeleportAttack")
			teleport_attack.setActionDelay(TELEPORT_ATTACK_ACTION_DELAY)
			
			
			var all_enemies: Array = adjacent_enemies + double_adjacent_enemies + triple_adjacent_enemies
			if !all_enemies.is_empty():
				var relative_rotation: int = Game.getRelativeTileRotation(TeleportTile, all_enemies.pick_random().getTile())
				actions += [teleport_enter, TeleportAction.new(self, TeleportTile), ChangeTileRotationAction.new(self, relative_rotation), teleport_attack]
			else: actions += [teleport_enter, TeleportAction.new(self, TeleportTile), teleport_attack]
				
			if i == 0: actions.insert(2, CardOffsetAction.new(self))
			actions.append(DamageAction.new(self, adjacent_enemies, attack, Game.DamageTypes.OTHER))
			actions.append(DamageAction.new(self, double_adjacent_enemies, attack - 1, Game.DamageTypes.OTHER))
			actions.append(DamageAction.new(self, triple_adjacent_enemies, attack - 2, Game.DamageTypes.OTHER))
		return actions
	return []
#endregion

#region Mist Attack
func onMistAttackSetIntents() -> BossTileIntents:
	var tile_intents: Array[TileIntentDatastore] = []
	var penta_adjacent_coords: Array = Game.getAdjacentOrCloserCoords(Vector4i.ZERO, 5)
	
	for coord: Vector4i in penta_adjacent_coords:
		var tile_intent := Game.TileIntents.PURPLE if Game.getCoordsDistance(Vector4i.ZERO, coord) <= 2 else Game.TileIntents.LIGHT_RED
		tile_intents.append(TileIntentDatastore.new(tile_intent, OffsetDatastore.new(coord), coords))
	
	return BossTileIntents.new(tile_intents, {})
	
func onMistAttack(use_type: UseType) -> Array:
	if use_type == UseType.START:
		var actions: Array = []
		
		var enemies: Array = Game.getEnemyUnits(team)
		var penta_adjacent_tiles: Array = Game.getAdjacentOrCloserTiles(Tile, 5)
		var attack_tiles: Array = penta_adjacent_tiles.filter(func(x: TileGD): return Game.getCoordsDistance(x.getCoords(), coords) <= 2)
		penta_adjacent_tiles = penta_adjacent_tiles.filter(func(x: TileGD): return x not in attack_tiles)
		
		actions += onApplyBlind(enemies, attack_tiles)
		actions.append(DamageAction.new(self, enemies.filter(func(x: CardGD): return x.getTile() in penta_adjacent_tiles), attack - 1, Game.DamageTypes.OTHER))		
		return actions
	return []
#endregion
	
#region Phase Change
const PHASE_TWO_BASE_HEALTH: int = 14
const PHASE_THREE_BASE_HEALTH: int = 7
const PHASE_CHANGE_DELAY_TIME: float = 3.0
func onChangeBossPhase() -> void:
	super()
	onForceAction(AnimationAction.new(self, "PhaseChange"))
	onForceAction(ClearTileIntentsAction.new())
	onForceAction(FieldInfoVisibleAction.new(self, false))
	
	var heal_to: int = PHASE_TWO_BASE_HEALTH if getPhase() == 2 else PHASE_THREE_BASE_HEALTH
	onPushAction(HealAction.new(HealDatastore.new(self, max(heal_to - health, 0))))

func onChangeBossPhasePostDelay() -> void:
	super()
	
	setIdleModifier("Hammer")
	var actions: Array = [ChangeTileRotationAction.new(self, 0),
		CardOffsetAction.new(self, Vector3.ZERO, HAMMER_ROT_OFFSET),
		TeleportAction.new(self, getPedestalTile())]
		
	var ally_cards: Array = Game.getAllyUnits(0)
	
	actions += ally_cards.map(func(x: CardGD): return RemoveStatusEffectAction.new(x.getStatusEffect(BLIND_ID)))
	
	var animation_action := AnimationAction.new(self, "HammerJump")
	animation_action.setActionDelay(HAMMER_JUMP_ACTION_DELAY)
	
	actions.append(animation_action)
	actions.append(FieldInfoVisibleAction.new(self, true))
	
	var intent_name: String = ""
	match getPhase():
		2: actions += onPhaseTwoPhaseChangePostDelay(); intent_name = "Clone Phase Change"
		3: actions += onPhaseThreePhaseChangePostDelay(); intent_name = "Dodge Phase Change"
	
	actions.append(ChangeBossIntentAction.new(getBossIntentByName(intent_name), true))
	var card_offset_action := CardOffsetAction.new(self, HAMMER_END_RELATIVE_POS, HAMMER_ROT_OFFSET)
	card_offset_action.setActionDelay(PHASE_CHANGE_DELAY_TIME)
	actions.append(card_offset_action)
	
	actions += ally_cards.map(func(x: CardGD): return x.getBaseStatusEffectAction(BLIND_ID, -1))
	
	if Game.getLevel().getPhase() == Game.Phases.PLAYER:
		actions.append(ChangePhaseAction.new(Game.Phases.AI))
	
	onPushAction(actions)
	
	await get_tree().create_timer(HAMMER_INITIAL_DELAY).timeout
	var tween := get_tree().create_tween()
	tween.tween_property(self, "position", HAMMER_END_RELATIVE_POS, HAMMER_FLY_TIME).as_relative().set_trans(Tween.TRANS_SINE)
	
	#await get_tree().create_timer(HAMMER_INITIAL_DELAY).timeout
	#Model.

func onPhaseTwoPhaseChangePostDelay() -> Array:
	var actions: Array = []
	var ally_cards: Array = Game.getAllyUnits(0)
			
	var chosen_triple_adjacent_tiles: Array = []
	for AllyCard: CardGD in ally_cards:
		var triple_adjacent_tiles: Array = Game.getAdjacentTiles(AllyCard.getTile(), 3)\
		.filter(func(x: TileGD): return x not in chosen_triple_adjacent_tiles)
		
		if triple_adjacent_tiles.is_empty(): continue
		triple_adjacent_tiles.shuffle()
		
		var BestTile: TileGD = triple_adjacent_tiles[0]
		chosen_triple_adjacent_tiles.append(BestTile)
		
		var CloneCard: CardGD = onCreateClone(BestTile, actions, Game.getRelativeTileRotation(BestTile, AllyCard.getTile()))
		actions += CloneCard.getStunActions(2)
	return actions
	
func onPhaseThreePhaseChangePostDelay() -> Array:
	var actions: Array = []
	onFirstUpdateTileIntents()
	return actions
#endregion

#region Hammer Attack
const HAMMER_JUMP_ACTION_DELAY: float = 1.8
const HAMMER_INITIAL_DELAY: float = 0.5
const HAMMER_FLY_TIME: float = 0.75
const HAMMER_END_RELATIVE_POS := Vector3(0, 8, -3)
const HAMMER_ROT_OFFSET := Vector3(0, -(PI / 6.0), 0)
const HAMMER_ATTACK_ACTION_DELAY: float = 3.6

func onHammerAttackSetIntents() -> BossTileIntents:
	var tile_intents: Array[TileIntentDatastore] = []
	var tile_results: Dictionary[TileGD, String] = {}
	
	if boss_datastore.getIntentDuration() == 1:
		var allies: Array = Game.getEnemyUnits(team)
		allies.shuffle()
		
		var fatigueless_allies: Array = allies.filter(func(x: CardGD): return x.getStatusEffect(FATIGUE_ID) == null)
		if fatigueless_allies.is_empty():
			fatigueless_allies = allies
		
		var AllyCard: CardGD = fatigueless_allies.pick_random()
		var CenterTile: TileGD = AllyCard.getTile()
		var protected_tiles: Array = Game.getAdjacentOrCloserTiles(AllyCard.getTile(), 2) + [CenterTile]
		
		var level_tiles: Array = get_tree().get_nodes_in_group("LevelTilesGD").filter(func(x: TileGD): return x.getHeight() < 5 and x not in protected_tiles)
		var unit_tiles: Array = Game.getUnitTiles()
		var potential_landing_tiles: Array = level_tiles.filter(func(x: TileGD): return !x.isSolid() and x not in unit_tiles and Game.getCoordsDistance(x.getCoords(), CenterTile.getCoords()) >= 5)
		
		var LandingTile: TileGD = potential_landing_tiles.pick_random()
		var landing_tiles: Array = Game.getAdjacentTiles(LandingTile, 1)
		
		tile_intents.append(TileIntentDatastore.new(Game.TileIntents.DARK_RED, null, LandingTile.getCoords()))
		for AdjacentTile: TileGD in landing_tiles:
			tile_intents.append(TileIntentDatastore.new(Game.TileIntents.DARK_RED, null, AdjacentTile.getCoords()))
	
		for LevelTile: TileGD in level_tiles:
			tile_intents.append(TileIntentDatastore.new(Game.TileIntents.RED, null, LevelTile.getCoords()))
	
		tile_results[LandingTile] = "LandingTile"
		tile_results[CenterTile] = "CenterTile"
	
	return BossTileIntents.new(tile_intents, tile_results)
	
func onHammerAttack(use_type: UseType) -> Array:
	var actions: Array = []
	if use_type == UseType.START:
		match boss_datastore.getIntentDuration():
			2: 
				var hammer_start := AnimationAction.new(self, "PhaseChange")
				hammer_start.setActionDelay(HAMMER_INITIAL_DELAY)
				
				actions = [
					IdleModifierAction.new(self, "Hammer"),
					hammer_start,
					ChangeTileRotationAction.new(self, 0),
					CardOffsetAction.new(self, Vector3.ZERO, HAMMER_ROT_OFFSET),
					TeleportAction.new(self, getPedestalTile())]
				
				var hammer_jump := AnimationAction.new(self, "HammerJump")
				hammer_jump.setActionDelay(HAMMER_JUMP_ACTION_DELAY)
				actions.append(hammer_jump)
				
				var card_offset_action := CardOffsetAction.new(self, HAMMER_END_RELATIVE_POS, HAMMER_ROT_OFFSET)
				actions.append(card_offset_action)
				
				await get_tree().create_timer(HAMMER_INITIAL_DELAY).timeout
				var tween := get_tree().create_tween()
				tween.tween_property(self, "position", HAMMER_END_RELATIVE_POS, HAMMER_FLY_TIME).as_relative().set_trans(Tween.TRANS_SINE)
			1:
				var hammer_attack := AnimationAction.new(self, "HammerAttack")
				hammer_attack.setActionDelay(HAMMER_ATTACK_ACTION_DELAY)
		
	return actions
#endregion

#region Clone Summon
const CLONE_SUMMON_AMOUNT: int = 4
func onCloneSummonSetIntents() -> BossTileIntents:
	var tile_intents: Array[TileIntentDatastore] = []
	var tile_results: Dictionary[TileGD, String] = {}
	
	var tiles: Array = getVisibleTiles().filter(func(x: TileGD): return !x.isSolid() or x.isOccupied() or x.getHeight() > 5)
	tiles.shuffle()
	
	tiles.resize(CLONE_SUMMON_AMOUNT)
	tiles = tiles.filter(func(x: TileGD): return x != null)
	
	for SummonTile: TileGD in tiles:
		tile_intents.append(TileIntentDatastore.new(Game.TileIntents.YELLOW, null, SummonTile.getCoords()))
		tile_results[SummonTile] = ""
	
	return BossTileIntents.new(tile_intents, tile_results)
	
func onCloneSummon(use_type: UseType) -> Array:
	var actions: Array = []
	if use_type == UseType.START:
		actions.append(FieldInfoVisibleAction.new(self, false))
		var tiles: Array = boss_datastore.getTileResults().keys().filter(func(x: TileGD): return !x.isOccupied())
		for SummonTile: TileGD in tiles:
			var CloneCard: CardGD = onCreateClone(SummonTile, actions)
			CloneCard.is_clone_summon = true
	return actions
	
func onCloneSummonDeathRevealIntent() -> void:
	if Game.getAllyUnits(team).any(func(x: CardGD): return x.info.id == CLONE_ID and x.is_clone_summon): return
	onPushAction(FieldInfoVisibleAction.new(self, true))
	
func onHurtRevealIntentIfCloneSummon() -> void:
	if !Game.getAllyUnits(team).any(func(x: CardGD): return x.info.id == CLONE_ID and x.is_clone_summon): return
	onPushAction(FieldInfoVisibleAction.new(self, true))
#endregion

#region Clone Minifan Attack
func onCloneMinifanAttackSetIntents() -> BossTileIntents:
	var tile_intents: Array[TileIntentDatastore] = []
	var tile_results: Dictionary[TileGD, String] = {}
	var fan_coords: Array = Game.getFanCoords(Vector4i.ZERO, 2)
	
	for fan_coord: Vector4i in fan_coords:
		tile_intents.append(TileIntentDatastore.new(Game.TileIntents.RED, OffsetDatastore.new(fan_coord, true, tile_rotation), coords))
	
	return BossTileIntents.new(tile_intents, {})
	
func onCloneMinifanAttack(enemies: Array, tiles: Array, use_type: UseType) -> Array:
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
		
		var animation_action := AnimationAction.new(self, "MiniFan")
		animation_action.setActionDelay(MINIFAN_ATTACK_ACTION_DELAY)
		actions.append(animation_action)
		
		actions.append(DamageAction.new(self, all_enemies, attack, Game.DamageTypes.OTHER))
	return actions
#endregion

#region Clone Phase Change
func onClonePhaseChangeSetIntents() -> BossTileIntents: return BossTileIntents.new()
	 
func onClonePhaseChange(use_type: UseType) -> Array:
	if use_type == UseType.END and boss_datastore.getIntentDuration() == 1:
		var allies: Array = Game.getAllyUnits(0)
		return allies.map(func(x: CardGD): return RemoveStatusEffectAction.new(x.getStatusEffect(BLIND_ID)))
	return []
#endregion

#region Dodge Phase Change
const DODGE_DOUBLE_ADJACENT_TILES: int = 3
func onDodgePhaseChangeSetIntents() -> BossTileIntents:
	var tile_intents: Array[TileIntentDatastore] = []
	var tile_results: Dictionary[TileGD, String] = {}
	
	if boss_datastore.getIntentDuration() == 1:
		var allies: Array = Game.getEnemyUnits(team)
		allies.shuffle()
		
		var chosen_double_adjacent_tiles: Array = []
		for AllyCard: CardGD in allies:
			var double_adjacent_tiles: Array = Game.getAdjacentTiles(AllyCard.getTile(), 2)
			double_adjacent_tiles.filter(func(x: TileGD): return x not in chosen_double_adjacent_tiles)
			
			if double_adjacent_tiles.is_empty(): continue
			
			var start_index: int = randi_range(0, double_adjacent_tiles.size() - 1)
			for i: int in range(3):
				var new_index: int = (start_index + i) % double_adjacent_tiles.size()
				var DoubleAdjacentTile: TileGD = double_adjacent_tiles[new_index]
				if DoubleAdjacentTile not in chosen_double_adjacent_tiles:
					chosen_double_adjacent_tiles.append(DoubleAdjacentTile)
	
		for LevelTile: TileGD in get_tree().get_nodes_in_group("LevelTilesGD")\
			.filter(func(x: TileGD): return x not in chosen_double_adjacent_tiles and x.getHeight() < 5):
			tile_intents.append(TileIntentDatastore.new(Game.TileIntents.RED, null, LevelTile.getCoords()))
	
	return BossTileIntents.new(tile_intents, tile_results)

func onDodgePhaseChange(use_type: UseType) -> Array:
	if use_type == UseType.END and boss_datastore.getIntentDuration() == 1:
		var allies: Array = Game.getAllyUnits(0)
		return allies.map(func(x: CardGD): return RemoveStatusEffectAction.new(x.getStatusEffect(BLIND_ID)))
	return []
#endregion

#region Helper
func onApplyBlind(enemies: Array, tiles: Array, turns: int = -1) -> Array: # Returns blind actions
	return enemies.filter(func(x: CardGD): return x.getTile() in tiles).map(func(x: CardGD): return x.getBaseStatusEffectAction(BLIND_ID, turns))

func getPedestalTile() -> TileGD: # Update this so it doesn't wreck ur pc
	return Game.getTile(PEDESTAL_TILE_COORDS)
	
func onCreateClone(CloneTile: TileGD, actions: Array, clone_rotation: int = randi_range(0, 5)) -> CardGD:
	var clone_data := Game.getBaseCard(CLONE_ID, CloneTile, team, clone_rotation, false)
	var CloneCard: CardGD = SavedData.onLoadModel(clone_data, Game.getLevel())
	actions.append(AwakenAction.new(CloneCard, CloneTile, true))
	return CloneCard
#endregion
