extends EpicCardGD
	
const PALMY_ID: int = 4
const ARMOR_TRAIT_ID: int = 1

var turns_enemies_unseen: int = 0 # -1 means an enemy was spotted and this stops counting, after TURNS_UNTIL_HUNT_MODE starts moving towards allies
const TURNS_UNTIL_HUNT_MODE: int = 3

var active_speed: int
	
#region Default
func onProcessAction(action: Action) -> void:
	super(action)
	if !action.post:
		if action is FallDamageAction and action.Card == self:
			action.onFailAction()
	elif action.post:
		if action is StatAction and action.hasCard(self) and health <= int(max_health / 2.0) and health > 0\
		and Game.ActionManagerReference.onFindFirstAction(ChangeBossPhaseAction) == null and getPhase() == 1:
			onPushAction(ChangeBossPhaseAction.new())
		elif action is VisionNewUnitAction and action.Discoverer == self and action.Discovered.isAlly(0):
			turns_enemies_unseen = -1
		elif action is MoveToTileAction and action.Card == self:
			active_speed = max(active_speed - 1, 0)
			
func onSave() -> SavedDataEpicCard:
	ability_save["turns_enemies_unseen"] = turns_enemies_unseen
	ability_save['active_speed'] = active_speed
	return super()
	
func onCardTurnPassed(Card: CardGD) -> void:
	super(Card)
	if self != Card: return
	if turns_enemies_unseen >= 0:
		turns_enemies_unseen += 1
#endregion
	
#region Boss Intent
func onUseBossIntent(enemies: Array, allies: Array, tiles: Array, use_type: UseType) -> void:
	var actions: Array = []
	match boss_intent.name:
		"Spin Attack":
			actions = onSpinAttack(enemies, tiles, use_type)
		"Reposition":
			actions = onReposition(enemies, tiles, use_type)
		"Rally":
			actions = onRally(enemies, allies, tiles, use_type)
		"Summon":
			actions = onSummon(enemies, tiles, use_type)
		"Charge Attack":
			actions = onChargeAttack(use_type)
		"Jump Attack":
			actions = onJumpAttack(use_type)
		"Maelstorm Attack":
			actions = onMaelstormAttack(enemies, use_type)
		"Bulk Up":
			actions = onBulkUp(use_type)
		"Run Away":
			actions = onRunAway(enemies, tiles, use_type)
		"Autoattack":
			actions = onAutoattack(enemies, allies, tiles, use_type)
		"Fan Attack":
			actions = onFanAttack(enemies, use_type)
		"Slash Attack":
			actions = onSlashAttack(enemies, tiles, use_type)
			
	onPushAction(BossIntentUsedAction.new(boss_intent, use_type, actions, enemies, allies))

const BULK_UP_CHANCE: float = 0.75
const ROLL_ATTACK_ODDS_LONE_RIDER: float = 0.66
const ROLL_ATTACK_ODDS: float = 0.5
func onChangeBossIntent(boss_intents: Array, enemies: Array, _allies: Array) -> BossIntent:
	match getPhase():
		1:
			if boss_intent != null and boss_intent.name == "Jump Attack":
				boss_intents = boss_intents.filter(func(x: BossIntent): return x.name != "Reposition")
				
			if !enemies.is_empty(): # If is in combat
				if boss_intents.all(func(x: BossIntent): return x.type in [x.IntentType.ATTACK, x.IntentType.MOVEMENT_ATTACK]): # Only attacks
					boss_intents = boss_intents.filter(func(x: BossIntent): return x.type in [x.IntentType.ATTACK, x.IntentType.MOVEMENT_ATTACK])
				elif boss_intents.all(func(x: BossIntent): return x.type not in [x.IntentType.ATTACK, x.IntentType.MOVEMENT_ATTACK]): # Only non attacks
					boss_intents = boss_intents.filter(func(x: BossIntent): return x.type not in [x.IntentType.ATTACK, x.IntentType.MOVEMENT_ATTACK])
				elif Random.rollFloat(ROLL_ATTACK_ODDS): # Rolled attack
					boss_intents = boss_intents.filter(func(x: BossIntent): return x.type in [x.IntentType.ATTACK, x.IntentType.MOVEMENT_ATTACK])
				else: # Rolled non attack
					boss_intents = boss_intents.filter(func(x: BossIntent): return x.type not in [x.IntentType.ATTACK, x.IntentType.MOVEMENT_ATTACK])
			else:
				boss_intents = boss_intents.filter(func(x: BossIntent): return x.name in ["Spin Attack", "Reposition", "Jump Attack"])
		2:
			if !enemies.is_empty(): # If in combat
				if Random.rollFloat(ROLL_ATTACK_ODDS_LONE_RIDER):
					boss_intents = boss_intents.filter(func(x: BossIntent): return x.type in [x.IntentType.ATTACK, x.IntentType.MOVEMENT_ATTACK])
				else:
					var new_boss_intents: Array = boss_intents.filter(func(x: BossIntent): return x.type not in [x.IntentType.ATTACK, x.IntentType.MOVEMENT_ATTACK])
					if new_boss_intents.size() == 2: # If more than one, otherwise guarantees
						if Random.rollFloat(BULK_UP_CHANCE):
							new_boss_intents = boss_intents.filter(func(x: BossIntent): return x.name == "Bulk Up")
						else:
							new_boss_intents = boss_intents.filter(func(x: BossIntent): return x.name == "Run Away")
					elif new_boss_intents.size() == 0: # Picks a random attack
						new_boss_intents = boss_intents.filter(func(x: BossIntent): return x.type in [x.IntentType.ATTACK, x.IntentType.MOVEMENT_ATTACK])
					boss_intents = new_boss_intents
			else:
				var new_boss_intents: Array = boss_intents.filter(func(x: BossIntent): return x.type not in [x.IntentType.ATTACK, x.IntentType.MOVEMENT_ATTACK])
				if new_boss_intents.size() == 2: # If more than one, otherwise guarantees
					if Random.rollFloat(BULK_UP_CHANCE):
						new_boss_intents = boss_intents.filter(func(x: BossIntent): return x.name == "Bulk Up")
					else:
						new_boss_intents = boss_intents.filter(func(x: BossIntent): return x.name == "Run Away")
				elif new_boss_intents.size() == 0: # Picks a random attack
					new_boss_intents = boss_intents.filter(func(x: BossIntent): return x.type in [x.IntentType.ATTACK, x.IntentType.MOVEMENT_ATTACK])
				boss_intents = new_boss_intents
	return boss_intents.pick_random()
	
func onCheckBossIntentCondition(conditional_boss_intent: BossIntent, _enemies: Array, allies: Array) -> bool:
	var condition_result: BossIntentConditionResult
	match conditional_boss_intent.name:
		"Rally":
			condition_result = onRallyCondition(allies)
		"Spin Attack":
			condition_result = onSpinAttackCondition()
		"Reposition":
			condition_result = onRepositionCondition()
		"Charge Attack":
			condition_result = onChargeAttackCondition()
		"Jump Attack":
			condition_result = onJumpAttackCondition()
		"Fan Attack":
			condition_result = onFanAttackCondition()
		_: condition_result = BossIntentConditionResult.new(true)
			
	boss_datastore.setConditionResult(condition_result, conditional_boss_intent.name)
	return condition_result.state
	
func onResetBossIntentCooldowns() -> void:
	super()
#endregion
	
#region Spin Attack
const SPIN_ATTACK_SPEED_LIMIT: int = 3
const SPIN_ATTACK_ACTION_DELAY: float = 2.5
func onSpinAttackSetIntents() -> BossTileIntents:
	var tile_intents: Array[TileIntentDatastore] = []
	for _offset: Vector3i in Game.cube_directions:
		var offset: Vector4i = Vector4i(_offset.x, _offset.y, _offset.z, 0)
		var offset_datastore := OffsetDatastore.new(offset)
		tile_intents.append(TileIntentDatastore.new(Game.TileIntents.RED, offset_datastore, getCoords()))
	return BossTileIntents.new(tile_intents, {})

func getSpinAttackTiles(CardTile: TileGD = Tile) -> Array:
	return Game.getAdjacentTiles(CardTile, 1)
	
func onSpinAttackCondition() -> BossIntentConditionResult: # Needs to be on the ground to use
	return BossIntentConditionResult.new(isGround())
	
func onSpinAttack(enemies: Array, tiles: Array, use_type: UseType) -> Array:
	if use_type == UseType.START: active_speed = SPIN_ATTACK_SPEED_LIMIT
	if use_type != UseType.END:
		tiles = getsetMovementRange(active_speed)
		if tiles.is_empty(): return []
		
		var BestTile: TileGD
		tiles = getUnoccupiedTiles(tiles)
		
		if !enemies.is_empty():
			var tile_to_adjacent_enemy_count: Dictionary = {}
			for OtherTile: TileGD in tiles:
				var adjacent_enemies: int = enemies.filter(func(x: CardGD): return Game.getCoordsDistance(OtherTile.getCoords(), x.getCoords()) == 1).size()
				tile_to_adjacent_enemy_count[OtherTile] = adjacent_enemies
			
			tiles.sort_custom(func(x: TileGD, y: TileGD): return tile_to_adjacent_enemy_count[x] > tile_to_adjacent_enemy_count[y])
			if tile_to_adjacent_enemy_count[tiles[0]] == 0: # If no adjacent enemies, use tactician logic
				tiles = getAllyVisionTiles(tiles)
				tiles = getDistantToEnemiesTiles(enemies, tiles)
		else:
			if turns_enemies_unseen >= TURNS_UNTIL_HUNT_MODE:
				tiles = getCloseToEnemiesTiles(Game.getEnemyUnits(team), tiles)
				BestTile = tiles[0]
			else: BestTile = tiles.pick_random()
				
			
		BestTile = tiles[0]
		return [MovementAction.new(self, BestTile.getMovementPathTiles())]
		
	var adjacent_tiles: Array = Game.getAdjacentTiles(Tile)
	var damagables: Array = adjacent_tiles.map(func(x: TileGD): return Game.getFieldCard(x)).filter(func(x: CardGD): return x != null and x.isEnemy(team))
	if damagables.is_empty(): return []
	
	var change_tile_rotation_action := ChangeTileRotationAction.new(self, Game.getRelativeTileRotation(getTile(), damagables.pick_random().getTile()))
	var animation_action := AnimationAction.new(self, "Spin Attack")
	animation_action.setActionDelay(SPIN_ATTACK_ACTION_DELAY)
	
	return [change_tile_rotation_action, animation_action, DamageAction.new(self, damagables, attack, Game.DamageTypes.ATTACK)]
#endregion

#region Reposition
func onReposition(enemies: Array, tiles: Array, use_type: UseType) -> Array:
	if use_type != UseType.END:
		tiles = getUnoccupiedTiles(tiles)
		if tiles.is_empty(): return []
		
		var BestTile: TileGD
		var tiles_adjacent_to_height: Array = []
		if !enemies.is_empty(): # If in combat reposition tries to go up
			for OtherTile: TileGD in tiles:
				for AdjacentTile: TileGD in Game.getAdjacentTiles(OtherTile):
					if isHigh(AdjacentTile):
						tiles_adjacent_to_height.append(OtherTile)
						break
						
			tiles_adjacent_to_height = tiles_adjacent_to_height.filter(func(x: TileGD): return !x.isSolid() and !x.isOccupied())
			if tiles_adjacent_to_height.is_empty():
				tiles_adjacent_to_height = tiles
				tiles_adjacent_to_height = getDistantToEnemiesTiles(enemies, tiles_adjacent_to_height)
			else:
				tiles_adjacent_to_height = getAllyVisionTiles(tiles_adjacent_to_height)
				tiles_adjacent_to_height = getCloseToEnemiesTiles(enemies, tiles_adjacent_to_height)
				
		else:
			tiles_adjacent_to_height = tiles
			tiles_adjacent_to_height.shuffle()
			if turns_enemies_unseen >= TURNS_UNTIL_HUNT_MODE:
				tiles_adjacent_to_height = getCloseToEnemiesTiles(Game.getEnemyUnits(team), tiles_adjacent_to_height)
		BestTile = tiles_adjacent_to_height[0]
		
		return [MovementAction.new(self, BestTile.getMovementPathTiles())]
	
	if isGround():
		var height_tiles: Array = Game.getAdjacentTiles(Tile)\
			.filter(func(x: TileGD): return isHigh(x) and !x.isSolid() and !x.isOccupied())
		if height_tiles.is_empty(): return []
		
		height_tiles = getAllyVisionTiles(height_tiles)
			
		var BestTile: TileGD = height_tiles.pick_random()
		return [MovementAction.new(self, [getTile(), BestTile]), ChangeTileRotationAction.new(self, Game.getRelativeTileRotation(Tile, BestTile))]
	return []
	
func onRepositionSetIntents() -> BossTileIntents: return BossTileIntents.new()
	
func onRepositionCondition() -> BossIntentConditionResult:
	return BossIntentConditionResult.new(isGround())
#endregion

#region Rally
const RALLY_ACTION_DELAY: float = 2.7
const RALLY_MINIMUM_PALMY_AMOUNT: int = 2
const RALLY_SPEED_LIMIT: int = 2
const PALMY_SPECTATE_DELAY: float = 1.2

func onRallyCondition(allies: Array) -> BossIntentConditionResult:
	return BossIntentConditionResult.new(allies.filter(func(x: CardGD): return x.info.id == PALMY_ID).size() >= RALLY_MINIMUM_PALMY_AMOUNT)
	
func onRallySetIntents() -> BossTileIntents:
	var tile_intents: Array[TileIntentDatastore] = []
	for Card: CardGD in Game.getAllyUnits(team):
		tile_intents.append(TileIntentDatastore.new(Game.TileIntents.GREEN, OffsetDatastore.new(Vector4i.ZERO, false), getCoords()))
	return BossTileIntents.new(tile_intents, {})
		
func onRally(enemies: Array, allies: Array, tiles: Array, use_type: UseType) -> Array:
	var actions: Array = []
	if use_type == UseType.START:
		var animation_action := AnimationAction.new(self, "Rally")
		animation_action.setActionDelay(RALLY_ACTION_DELAY)
		actions.append(animation_action)
		
		for PalmyCard: CardGD in allies.filter(func(x: CardGD): return x.info.id == PALMY_ID):
			var camera_change_action := CameraChangeAction.new(PalmyCard)
			camera_change_action.setActionDelay(PALMY_SPECTATE_DELAY)
			actions.append(StatAction.new(StatInfo.new(PalmyCard, Game.Stats.ATTACK, 1)))
			actions.append(camera_change_action)
			
		actions.append(ClearTileIntentsAction.new())
		
		tiles = getsetMovementRange(RALLY_SPEED_LIMIT)
		tiles = getUnoccupiedTiles(tiles)
		tiles = getAllyVisionTiles(tiles)
		tiles = onRemoveGroundTilesWhenNotOnGround(tiles)
		tiles = getDistantToEnemiesTiles(enemies, tiles)
		
		if !tiles.is_empty():
			var BestTile: TileGD = tiles[0]
			actions.append(MovementAction.new(self, BestTile.getMovementPathTiles()))
	return actions
#endregion

#region Summon
const PALMY_SUMMONING_ACTION_DELAY: float = 1.2
const SUMMON_ACTION_DELAY: float = 2.7
const SUMMON_SPEED_LIMIT: int = 2
const SUMMON_AMOUNT: int = 3
func onSummon(enemies: Array, tiles: Array, use_type: UseType) -> Array:
	var actions: Array = []
	if use_type == UseType.START:
		var animation_action := AnimationAction.new(self, "Summon")
		animation_action.setActionDelay(SUMMON_ACTION_DELAY)
		actions.append(animation_action)
		
		var chosen_tiles: Array = boss_datastore.getTileResults().keys().filter(func(x: TileGD): return x != null and !x.isSolid() and !x.isOccupied())
		for PalmyTile: TileGD in chosen_tiles:
			var Palmy: CardGD = Game.getNewFieldCard(PALMY_ID, PalmyTile, team, 0, tier, true)
			actions.append(AwakenAction.new(Palmy, PalmyTile))
			
			var camera_change_action := CameraChangeAction.new(Palmy)
			camera_change_action.setActionDelay(PALMY_SUMMONING_ACTION_DELAY)
			actions.append(camera_change_action)
		
		actions.append(ClearTileIntentsAction.new())
		var ally_vision: Array = Game.getTeamVision(0)
		tiles = getsetMovementRange(SUMMON_SPEED_LIMIT)
		tiles = tiles.filter(func(x: TileGD): return x not in chosen_tiles and x.getMovementPathTiles().all(func(y: TileGD): return y not in chosen_tiles))
		
		if !ally_vision.is_empty():
			tiles = tiles.filter(func(x: TileGD): return x in ally_vision)
			
		tiles = getAllyVisionTiles(tiles)
		tiles = getUnoccupiedTiles(tiles)
		tiles = onRemoveGroundTilesWhenNotOnGround(tiles)
		tiles = getDistantToEnemiesTiles(enemies, tiles)
		
		if !tiles.is_empty():
			var BestTile: TileGD = tiles[0]
			actions.append(MovementAction.new(self, BestTile.getMovementPathTiles()))
	return actions
	
func onSummonSetIntents() -> BossTileIntents:
	var tile_intents: Array[TileIntentDatastore] = []
	var tiles: Array = getVisibleTiles().filter(func(x: TileGD): return !x.isOccupied() and !x.isSolid())
	tiles = tiles.filter(func(x: TileGD): return isGround(x))
	tiles.shuffle()
	tiles.resize(SUMMON_AMOUNT)
	tiles = tiles.filter(func(x: TileGD): return x != null)
	
	var tile_results: Dictionary[TileGD, String] = {}
	for PalmyTile: TileGD in tiles:
		tile_intents.append(TileIntentDatastore.new(Game.TileIntents.YELLOW, null, PalmyTile.getCoords()))
		tile_results[PalmyTile] = ""
	return BossTileIntents.new(tile_intents, tile_results)
#endregion

#region Jump Attack
const ADJACENT_DAMAGE: int = 2
const DOUBLE_ADJACENT_DAMAGE: int = 1
func onJumpAttackSetIntents() -> BossTileIntents:
	var tile_intents: Array[TileIntentDatastore] = []
	var enemies: Array = getVisibleFieldCardsEnemies()
	var CenterTile: TileGD
	
	if !enemies.is_empty():
		CenterTile = enemies.pick_random().getTile()
	else:
		var tiles: Array = getVisibleTiles()
		tiles = onRemoveHighTiles(tiles)
		CenterTile = tiles.pick_random()
	
	tile_intents.append(TileIntentDatastore.new(Game.TileIntents.DARK_RED, null, CenterTile.getCoords()))
	for AdjacentTile in Game.getAdjacentTiles(CenterTile, 1):
		tile_intents.append(TileIntentDatastore.new(Game.TileIntents.RED, null, AdjacentTile.getCoords()))
	
	for DoubleAdjacentTile in Game.getAdjacentTiles(CenterTile, 2):
		tile_intents.append(TileIntentDatastore.new(Game.TileIntents.LIGHT_RED, null, DoubleAdjacentTile.getCoords()))
	return BossTileIntents.new(tile_intents, {CenterTile: ""})
		
func onJumpAttack(use_type: UseType) -> Array:
	var actions: Array = []
	if use_type == UseType.START:
		var CenterTile: TileGD = boss_datastore.getTileResults().keys()[0]
		actions.append(MoveToTileAction.new(self, CenterTile, true))
		
	elif use_type == UseType.END:
		var CenterTile: TileGD = boss_datastore.getTileResults().keys()[0]
		var enemies: Array = Game.getEnemyUnits(team)
		
		var adjacent_tiles: Array = Game.getAdjacentTiles(CenterTile, 1)
		var adjacent_enemies: Array = enemies.filter(func(x: CardGD): return x.getTile() in adjacent_tiles)
		if !adjacent_enemies.is_empty():
			actions.append(DamageAction.new(self, adjacent_enemies, ADJACENT_DAMAGE, Game.DamageTypes.OTHER))
			
		var double_adjacent_tiles: Array = Game.getAdjacentTiles(CenterTile, 2)
		var double_adjacent_enemies: Array = enemies.filter(func(x: CardGD): return x.getTile() in double_adjacent_tiles)
		if !double_adjacent_enemies.is_empty():
			actions.append(DamageAction.new(self, double_adjacent_enemies, DOUBLE_ADJACENT_DAMAGE, Game.DamageTypes.OTHER))
	return actions
	
func onJumpAttackCondition() -> BossIntentConditionResult:
	return BossIntentConditionResult.new(isHigh())
#endregion

#region Charge Attack
const CHARGE_ATTACK_HIT_ACTION_DELAY: float = 1.5
const MAX_CHARGE_DISTANCE: int = 4
func onChargeAttackCondition() -> BossIntentConditionResult:
	var condition_result := BossIntentConditionResultChargeAttack.new(false)
	if isHigh(): return condition_result
	
	var wall_adjacent_origin_tiles: Dictionary = {}
	for diagonal in Game.cube_directions:
		var diagonal_tiles: Array = []
		for i in range(1, MAX_CHARGE_DISTANCE + 1): # Checks each diagonal until it reaches a wall, a solid object or occupied tile or runs out of tiles
			var multed_diagonal := Vector4i(diagonal.x * i, diagonal.y * i, diagonal.z * i, 0)
			var DiagonalTile: TileGD = Game.getTile(multed_diagonal + coords)
			if DiagonalTile != null:
				if isHigh(DiagonalTile):
					wall_adjacent_origin_tiles[DiagonalTile] = diagonal_tiles
					break
				elif DiagonalTile.isSolid():
					break
				diagonal_tiles.append(DiagonalTile)
					
	if wall_adjacent_origin_tiles.is_empty(): return condition_result # If nothing found
	
	var enemies: Array = Game.getEnemyUnits(team)
	var enemy_tiles: Array = enemies.map(func(x: CardGD): return x.getTile())
	for OriginWallTile: TileGD in wall_adjacent_origin_tiles.keys():
		var wall_adjacent_tiles: Array = getWallAdjacentTiles(OriginWallTile, 2)
		for AdjacentTile: TileGD in wall_adjacent_tiles:
			if AdjacentTile in enemy_tiles:
				condition_result.setWallAdjacentTiles(wall_adjacent_tiles)
				condition_result.setChargeTiles(wall_adjacent_origin_tiles[OriginWallTile])
				condition_result.setState(true)
				return condition_result
	return condition_result
	
func getChargeIntentTiles(directions: Array) -> Dictionary:
	for diagonal in directions:
		var tiles: Dictionary = {}
		for i in range(1, MAX_CHARGE_DISTANCE + 1): # Checks each diagonal until it reaches a wall, a solid object or occupied tile or runs out of tiles
			var multed_diagonal := Vector4i(diagonal.x * i, diagonal.y * i, diagonal.z * i, 0)
			var DiagonalTile: TileGD = Game.getTile(multed_diagonal + coords)
			if DiagonalTile != null:
				if DiagonalTile.isSolid():
					break
			else:
				multed_diagonal.w = 4
				DiagonalTile = Game.getTile(multed_diagonal + coords)
				if DiagonalTile != null:
					for WallAdjacentTile: TileGD in getWallAdjacentTiles(DiagonalTile):
						tiles[WallAdjacentTile] = "WallAdjacentTile"
					
					multed_diagonal -= Vector4i(diagonal.x, diagonal.y, diagonal.z, 4)
					DiagonalTile = Game.getTile(multed_diagonal + coords)
					tiles[DiagonalTile] = "ChargeEndTile"
					
					for j in range(max(i - 2, 0)):
						multed_diagonal -= Vector4i(diagonal.x, diagonal.y, diagonal.z, 0)
						DiagonalTile = Game.getTile(multed_diagonal + coords)
						tiles[DiagonalTile] = "DiagonalTile"
					
					return tiles
				break
	return {}
	
func setWallTiles(PointTile: TileGD, wall_tiles: Dictionary = {}) -> void:
	var height_tiles: Array = Game.getAdjacentTiles(PointTile).filter(func(x: TileGD): return isHigh(x) and x not in wall_tiles.keys())
	if height_tiles.is_empty(): return
	
	for HeightTile: TileGD in height_tiles:
		wall_tiles[HeightTile] = null
		
	for HeightTile: TileGD in height_tiles:
		setWallTiles(HeightTile, wall_tiles)
	
func getWallAdjacentTiles(OriginTile: TileGD, distance: int = 2) -> Array:
	var wall_adjacent_tiles: Dictionary = {}
	var wall_tiles: Dictionary = {}
	setWallTiles(OriginTile, wall_tiles)
	
	for WallTile: TileGD in wall_tiles.keys():
		for AdjacentTile: TileGD in Game.getAdjacentOrCloserTiles(WallTile, distance).filter(func(x: TileGD): return isGround(x)):
			wall_adjacent_tiles[AdjacentTile] = null
	return wall_adjacent_tiles.keys()
	
func onChargeAttackSetIntents() -> BossTileIntents:
	var tile_intents: Array[TileIntentDatastore] = []
	var directions: Array = Game.cube_directions.duplicate()
	directions.shuffle()
	
	var tile_to_type: Dictionary = getChargeIntentTiles(directions)
	tile_to_type[getTile()] = "" # So it doesn't show any intent
	
	var condition_result: BossIntentConditionResultChargeAttack = boss_datastore.getConditionResult("Charge Attack")
	for IntentTile: TileGD in condition_result.getWallAdjacentTiles():
		if IntentTile != Tile:
			tile_intents.append(TileIntentDatastore.new(Game.TileIntents.RED, null, IntentTile.getCoords()))
	
	for IntentTile: TileGD in condition_result.getChargeTiles():
		if IntentTile != Tile:
			tile_intents.append(TileIntentDatastore.new(Game.TileIntents.DARK_RED, null, IntentTile.getCoords()))
	return BossTileIntents.new(tile_intents, {condition_result.getChargeEndTile(): ""})
	
func onChargeAttack(use_type: UseType) -> Array:
	var actions: Array = []
	var ChargeEndTile: TileGD = boss_datastore.getTileResults().keys()[0]
	if use_type == UseType.START:
		var path: Array = []
		if ChargeEndTile == getTile() or ChargeEndTile == null: return []
		else: path = ChargeEndTile.getMovementPathTiles()
		
		anibility_datastore.setWalkModifier("ChargeAttack")
		actions.append(MovementAction.new(self, path, true))
		
	elif use_type == UseType.END:
		var condition_result: BossIntentConditionResultChargeAttack = boss_datastore.getConditionResult("Charge Attack")
		var wall_adjacent_tiles: Array = condition_result.getWallAdjacentTiles()
		var enemies: Array = Game.getEnemyUnits(team).filter(func(x: CardGD): return x.getTile() in wall_adjacent_tiles)
		
		anibility_datastore.onResetWalkModifier()
		var animation_action := AnimationAction.new(self, "WalkChargeAttackHit")
		animation_action.setActionDelay(CHARGE_ATTACK_HIT_ACTION_DELAY)
		actions.append(animation_action)
		actions.append(DamageAction.new(self, enemies, 2, Game.DamageTypes.OTHER))
	return actions
#endregion

#region Maelstorm Attack
const MAELSTORM_ATTACK_ACTION_DELAY: float = 2.5
const MAELSTORM_SPEED_LIMIT: int = 1
func onMaelstormAttackSetIntents() -> BossTileIntents:
	var tile_intents: Array[TileIntentDatastore] = []
	var adjacent_tiles: Array = Game.getAdjacentTiles(Tile, 1)
	var double_adjacent_tiles: Array = Game.getAdjacentTiles(Tile, 2)
	var triple_adjacent_tiles: Array = Game.getAdjacentTiles(Tile, 3)
	
	for OtherTile: TileGD in adjacent_tiles:
		tile_intents.append(TileIntentDatastore.new(Game.TileIntents.DARK_RED, null, OtherTile.getCoords()))
		
	for OtherTile: TileGD in double_adjacent_tiles:
		tile_intents.append(TileIntentDatastore.new(Game.TileIntents.RED, null, OtherTile.getCoords()))
		
	for OtherTile: TileGD in triple_adjacent_tiles:
		tile_intents.append(TileIntentDatastore.new(Game.TileIntents.LIGHT_RED, null, OtherTile.getCoords()))
	return BossTileIntents.new(tile_intents, {})

func onMaelstormAttack(enemies: Array, use_type: UseType) -> Array:
	var actions: Array = []
	if use_type == UseType.START:
		var all_enemies: Array = Game.getEnemyUnits(team)
		var adjacent_enemies: Array = all_enemies.filter(func(x: CardGD): return Game.getCoordsDistance(x.getCoords(), coords) == 1)
		var double_adjacent_enemies: Array = all_enemies.filter(func(x: CardGD): return Game.getCoordsDistance(x.getCoords(), coords) == 2)
		var triple_adjacent_enemies: Array = all_enemies.filter(func(x: CardGD): return Game.getCoordsDistance(x.getCoords(), coords) == 3)
		
		var extra_attack: int = getExtraAttack()
		var animation_action := AnimationAction.new(self, "Maelstrom Attack")
		animation_action.setActionDelay(MAELSTORM_ATTACK_ACTION_DELAY)
		actions.append(animation_action)
		
		actions.append(DamageAction.new(self, adjacent_enemies, 3 + extra_attack, Game.DamageTypes.OTHER))
		for EnemyCard: CardGD in adjacent_enemies:
			actions.append(KnockbackStartAction.new(EnemyCard, self, 3, Game.getRelativeTileRotation(getTile(), EnemyCard.getTile())))

		actions.append(DamageAction.new(self, double_adjacent_enemies, 2 + extra_attack, Game.DamageTypes.OTHER))
		for EnemyCard: CardGD in double_adjacent_enemies:
			actions.append(KnockbackStartAction.new(EnemyCard, self, 2, Game.getRelativeTileRotation(getTile(), EnemyCard.getTile())))

		actions.append(DamageAction.new(self, triple_adjacent_enemies, 1 + extra_attack, Game.DamageTypes.OTHER))
		for EnemyCard: CardGD in triple_adjacent_enemies:
			actions.append(KnockbackStartAction.new(EnemyCard, self, 1, Game.getRelativeTileRotation(getTile(), EnemyCard.getTile())))
			
		actions.append(ClearTileIntentsAction.new())
		var tiles: Array = getsetMovementRange(MAELSTORM_SPEED_LIMIT)

		tiles = getAllyVisionTiles(tiles)
		tiles = getUnoccupiedTiles(tiles)
		
		if isHigh():
			tiles = onRemoveHighTiles(tiles)
		else:
			tiles = getDistantToEnemiesTiles(enemies, tiles)
		
		if !tiles.is_empty():
			var BestTile: TileGD = tiles[0]
			actions.append(MovementAction.new(self, BestTile.getMovementPathTiles()))
	return actions
#endregion

#region Bulk Up
const BULK_UP_MIN_HEALTH_FOR_HEAL: int = 2
const BULK_UP_HEAL_AMOUNT: int = 2
const BULK_UP_ACTION_DELAY: float = 2.0

func onBulkUpSetIntents() -> BossTileIntents:
	var tile_intents: Array[TileIntentDatastore] = []
	tile_intents.append(TileIntentDatastore.new(Game.TileIntents.GREEN, OffsetDatastore.new(), coords))
	return BossTileIntents.new(tile_intents, {})

func onBulkUp(use_type: UseType) -> Array:
	var actions: Array = []
	if use_type == UseType.START:
		var trait_data := SavedDataTrait.new(ARMOR_TRAIT_ID, true, 0, 1)
		
		var overworld_trait := OverworldTrait.new(trait_data, OverworldTrait.AddedBy.LONE_RIDER, true, 3)
		var animation_action := AnimationAction.new(self, "Bulk Up")
		animation_action.setActionDelay(BULK_UP_ACTION_DELAY)
		actions.append(animation_action)
		actions.append(AddOverworldTraitAction.new(self, overworld_trait, true))
		actions.append(StatAction.new(StatInfo.new(self, [Game.Stats.ATTACK, Game.Stats.SPEED], [1, 1], 3)))
			
		if health <= BULK_UP_MIN_HEALTH_FOR_HEAL:
			actions.append(HealAction.new(HealDatastore.new(self, BULK_UP_HEAL_AMOUNT)))
	
	return actions

func getExtraAttack() -> int:
	return attack - getAttackFromInfo()
#endregion

#region Run Away
const RUN_AWAY_SPEED: int = 3
func onRunAway(enemies: Array, tiles: Array, use_type: UseType) -> Array:
	if use_type == UseType.END: return []
	if use_type == UseType.RECALCULATE and speed == 0: return []
	
	if use_type == UseType.START: active_speed = RUN_AWAY_SPEED
	
	tiles = getsetMovementRange(active_speed)
	
	var actions: Array = []
	tiles = getAllyVisionTiles(tiles)
	tiles = getUnoccupiedTiles(tiles)
	tiles = getDistantToEnemiesTiles(enemies, tiles)
	
	if !tiles.is_empty():
		var BestTile: TileGD = tiles[0]
		actions.append(MovementAction.new(self, BestTile.getMovementPathTiles()))
	return actions
	
func onRunAwaySetIntents() -> BossTileIntents: return BossTileIntents.new()
#endregion

#region Autoattack
func onAutoattack(enemies: Array, allies: Array, tiles: Array, use_type: UseType) -> Array:
	var actions: Array = []
	
	if tiles.is_empty(): return []
	if use_type == UseType.END: return []
	if enemies.is_empty(): return [MovementAction.new(self, tiles.pick_random().getMovementPathTiles())]
	
	var DFL := DefaultFightLogic.new(self, tiles, enemies, allies)
	var path: Array = DFL.getKillPath()
	if path.is_empty():
		var attackables: Array = enemies.filter(func(x: CardGD): return x.getTile() in tiles)
		if !attackables.is_empty():
			attackables.sort_custom(func(x: CardGD, y: CardGD): return x.energy > y.energy)
			path = attackables[0].getTile().getMovementPathTiles()
		else:
			var ally_vision: Array = Game.getTeamVision(0)
			if !ally_vision.is_empty():
				tiles = tiles.filter(func(x: TileGD): return x in ally_vision)
		
			tiles = getDistantToEnemiesTiles(enemies, tiles)
			path = tiles[0].getMovementPathTiles()
			
	if !path.is_empty():
		actions.append(MovementAction.new(self, path))
	return actions
	
func onAutoattackSetIntents() -> BossTileIntents: return BossTileIntents.new()
#endregion

#region Fan Attack
const FAN_ATTACK_SPEED_LIMIT: int = 1
const FAN_ATTACK_ACTION_DELAY: float = 2.0
func onFanAttackCondition() -> BossIntentConditionResult:
	var condition_result := BossIntentConditionResultFanAttack.new(false)
	var enemy_tiles: Array = Game.getEnemyUnits(team).map(func(x: CardGD): return x.getTile())
	var diagonal_tile_to_enemy_count: Dictionary[TileGD, int] = {}
	var cube_directions: Array = Game.cube_directions.duplicate()
	cube_directions.shuffle()
	
	for diag in cube_directions:
		var diagonal := Vector4i(diag.x, diag.y, diag.z, 0) * 2
		var TripleAdjacentDiagonalTile: TileGD = Game.getTile(coords + diagonal)
		if TripleAdjacentDiagonalTile == null: continue
		
		var adjacent_tiles: Array = Game.getAdjacentTiles(TripleAdjacentDiagonalTile) + [TripleAdjacentDiagonalTile]
		diagonal_tile_to_enemy_count[TripleAdjacentDiagonalTile] = adjacent_tiles.filter(func(x: TileGD): return x in enemy_tiles).size()
		
	var diagonal_tiles: Array = diagonal_tile_to_enemy_count.keys()
	if diagonal_tiles.is_empty(): return condition_result
	
	diagonal_tiles.sort_custom(func(x: TileGD, y: TileGD): return diagonal_tile_to_enemy_count[x] > diagonal_tile_to_enemy_count[y])
	if diagonal_tile_to_enemy_count[diagonal_tiles[0]] > 0:
		condition_result.state = true
		condition_result.setTripleAdjacentDiagonalTile(diagonal_tiles[0])
	return condition_result

func onFanAttackSetIntents() -> BossTileIntents:
	var tile_intents: Array[TileIntentDatastore] = []
	var TripleAdjacentDiagonalTile: TileGD = boss_datastore.getConditionResult("Fan Attack").getTripleAdjacentDiagonalTile()
	var tiles: Array = Game.getAdjacentOrCloserTiles(TripleAdjacentDiagonalTile, 2) + [TripleAdjacentDiagonalTile]
	var fan_edge_tiles: Array = getFanEdgeTiles(TripleAdjacentDiagonalTile)
	
	var tile_results: Dictionary[TileGD, String] = {TripleAdjacentDiagonalTile: "TripleAdjacentDiagonalTile"}
	for FanEdgeTile: TileGD in fan_edge_tiles:
		tiles.append(FanEdgeTile)
		tile_results[FanEdgeTile] = "FanEdgeTile"
		
	tiles.erase(Tile)
	for NewTile: TileGD in tiles:
		tile_intents.append(TileIntentDatastore.new(Game.TileIntents.RED, null, NewTile.getCoords()))
	return BossTileIntents.new(tile_intents, tile_results)
	
func onFanAttack(enemies: Array, use_type: UseType) -> Array:
	if use_type == UseType.START:
		var tile_results: Dictionary[TileGD, String] = boss_datastore.getTileResults()
		var attack_tiles: Array = []
		var TripleAdjacentDiagonalTile: TileGD
		for BossIntentTile: TileGD in tile_results.keys():
			match tile_results[BossIntentTile]:
				"TripleAdjacentDiagonalTile": 
					TripleAdjacentDiagonalTile = BossIntentTile
			attack_tiles.append(BossIntentTile)
		
		attack_tiles += Game.getAdjacentOrCloserTiles(TripleAdjacentDiagonalTile, 2)
		attack_tiles.erase(self)
		
		var rotation_action := ChangeTileRotationAction.new(self, Game.getRelativeTileRotation(Tile, TripleAdjacentDiagonalTile))
		
		var animation_action := AnimationAction.new(self, "Fan Attack")
		animation_action.setActionDelay(FAN_ATTACK_ACTION_DELAY)
		
		var all_enemies: Array = Game.getEnemyUnits(team).filter(func(x: CardGD): return x.getTile() in attack_tiles)
		var damage_action := DamageAction.new(self, all_enemies, attack, Game.DamageTypes.ATTACK)
		
		var actions: Array = [rotation_action, animation_action, ClearTileIntentsAction.new(), damage_action]
		
		var tiles: Array = getsetMovementRange(FAN_ATTACK_SPEED_LIMIT)
		
		tiles = getAllyVisionTiles(tiles)
		tiles = getUnoccupiedTiles(tiles)
		tiles = getDistantToEnemiesTiles(enemies, tiles)
		
		if !tiles.is_empty():
			var BestTile: TileGD = tiles[0]
			actions.append(MovementAction.new(self, BestTile.getMovementPathTiles()))
		return actions
	return []

func getFanEdgeTiles(TripleAdjacentDiagonalTile: TileGD) -> Array:
	var d: Vector4i = (TripleAdjacentDiagonalTile.getCoords() - coords) / 2
	var diagonal := Vector3i(d.x, d.y, d.z)
	var index: int = Game.cube_directions.find(diagonal)
	
	var next_index: int = (index + 1) % 6
	var previous_index: int = (index - 1) % 6
	var tiles: Array = []
	for new_index: int in [next_index, previous_index]:
		var diag: Vector3i = Game.cube_directions[new_index]
		var new_diagonal := Vector4i(diag.x, diag.y, diag.z, 0)
		for i in range(3, 5): # 3 -> 4
			var multed_diagonal := new_diagonal * i
			var NewTile: TileGD = Game.getTile(multed_diagonal + coords)
			
			if i == 4:
				var relative_rotation: int = Game.getRelativeTileRotationCoords(multed_diagonal, d * i)
				var cube_d: Vector3i = Game.cube_directions[relative_rotation]
				var cube_direction := Vector4i(cube_d.x, cube_d.y, cube_d.z, 0)
				var OtherTile: TileGD = Game.getTile(multed_diagonal + coords + cube_direction)
				if OtherTile != null: tiles.append(OtherTile)
				
			if NewTile != null: tiles.append(NewTile)
				
	return tiles
#endregion

#region Slash Attack
const SLASH_ATTACK_ACTION_DELAY: float = 2.0
func onSlashAttackSetIntents() -> BossTileIntents:
	var tile_intents: Array[TileIntentDatastore] = []
	var new_coords: Array = []
	var direction: Vector4i = Game.getCubeDirectionExtra(0)
	new_coords = [direction, direction * 2, direction * 3]
	
	for x: Vector4i in new_coords:
		tile_intents.append(TileIntentDatastore.new(Game.TileIntents.RED, OffsetDatastore.new(x, true, tile_rotation), coords))
	return BossTileIntents.new(tile_intents, {})

func onSlashAttack(enemies: Array, tiles: Array, use_type: UseType) -> Array:
	if use_type == UseType.END: tiles.append(getTile()) # Add self to attack from here
	
	var DFL := DefaultFightLogic.new(self, tiles, enemies, [])
	var potential_killables: Array = enemies.filter(func(x: CardGD): return DFL.isAttackableKillable(x, self))
	var attackables: Dictionary[CardGD, TileGD] = getSlashAttackables(potential_killables, tiles)
	
	if attackables.values().all(func(x: TileGD): return x == null):
		var potential_attackables: Array = enemies.filter(func(x: CardGD): return x not in potential_killables)
		attackables = getSlashAttackables(potential_attackables, tiles)
	
	var no_attackables: bool = attackables.values().all(func(x: TileGD): return x == null)
	var actions: Array = []
	var BestTile: TileGD
	
	if use_type != UseType.END:
		if no_attackables:
			tiles = getAllyVisionTiles(tiles)
			tiles = getUnoccupiedTiles(tiles)
			tiles = getDistantToEnemiesTiles(enemies, tiles)
			
			if !tiles.is_empty():
				BestTile = tiles[0]
		else:
			var attackables_array: Array = attackables.keys().filter(func(x: CardGD): return attackables[x] != null)
			attackables_array.sort_custom(func(x: CardGD, y: CardGD): return x.energy > y.energy)
			BestTile = attackables[attackables_array[0]]
			
		if BestTile != null:
			actions.append(MovementAction.new(self, BestTile.getMovementPathTiles()))
				
	elif use_type == UseType.END: # Rotates towards and enemies and applies damage
		if no_attackables: return []
		var attackables_array: Array = attackables.keys().filter(func(x: CardGD): return attackables[x] != null)
		attackables_array.sort_custom(func(x: CardGD, y: CardGD): return x.energy > y.energy)
		BestTile = attackables_array[0].getTile()
		
		var relative_tr: int = Game.getRelativeTileRotation(Tile, BestTile)
		actions.append(ChangeTileRotationAction.new(self, relative_tr))
		
		var diagonal: Vector4i = Game.getCubeDirectionExtra(relative_tr)
		var all_enemies: Array = Game.getEnemyUnits(team)
		var all_enemy_tiles: Array = all_enemies.map(func(x: CardGD): return x.getTile())
		var damagables: Array = []
		
		for i in range(1, 4):
			var multed_diagonal := diagonal * i
			var NewTile: TileGD = Game.getTile(multed_diagonal + coords)
			
			if NewTile != null:
				var index: int = all_enemy_tiles.find(NewTile)
				if index == -1: continue
				damagables.append(all_enemies[index])
		
		var animation_action := AnimationAction.new(self, "Slash Attack")
		animation_action.setActionDelay(SLASH_ATTACK_ACTION_DELAY)
		actions.append(animation_action)
		actions.append(DamageAction.new(self, damagables, attack, Game.DamageTypes.OTHER))
	return actions
	
func getSlashAttackables(enemies: Array, tiles: Array) -> Dictionary[CardGD, TileGD]:
	var attackables: Dictionary[CardGD, TileGD] = {}
	for EnemyCard: CardGD in enemies:
		attackables[EnemyCard] = isSlashEnemyAttackable(EnemyCard, tiles)
	return attackables
	
func isSlashEnemyAttackable(EnemyCard: CardGD, tiles: Array) -> TileGD:
	var cube_directions: Array = Game.getCubeDirectionsExtra()
	cube_directions.shuffle()
	for diagonal: Vector4i in cube_directions:
		for i in range(3, 0, -1):
			var multed_diagonal: Vector4i = diagonal * i
			var NewTile: TileGD = Game.getTile(EnemyCard.getCoords() + multed_diagonal)
			if NewTile != null and NewTile in tiles:
				return NewTile
	return null
#endregion

#region Helper
func isGround(_Tile: TileGD = getTile()) -> bool:
	return _Tile.getHeight() == 10
	
func isHigh(_Tile: TileGD = getTile()) -> bool:
	return _Tile.getHeight() > 10
	
func onRemoveHighTiles(tiles: Array) -> Array:
	if isHigh():
		return tiles.filter(func(x: TileGD): return isGround(x))
	return tiles

func onRemoveGroundTilesWhenNotOnGround(tiles: Array) -> Array:
	if isHigh():
		return tiles.filter(func(x: TileGD): return isHigh(x))
	return tiles
#endregion

#region Phase Change
func onChangeBossPhase() -> void:
	super()
	onForceAction(FieldInfoVisibleAction.new(self, false))
	anibility_datastore.setDeathModifier("PhaseChange")
	onDeath()
	
func onChangeBossPhasePostDelay() -> void:
	super()
	onForceAction(FieldInfoVisibleAction.new(self, true))
	onIdle()
	
	anibility_datastore.setDeathModifier("")
	var actions: Array = []
	actions.append(ChangeBossIntentAction.new(getBossIntentByName("Maelstorm Attack")))
	
	var palmies: Array = Game.getAllyUnits(team).filter(func(x: CardGD): return x.info.id == PALMY_ID)
	actions.append(StatAction.new(palmies.map(func(x: CardGD): return StatInfo.new(x, Game.Stats.ATTACK, 1))))
	actions.append(CameraSpectateGroupAction.new(0))
	
	onPushAction(actions)
#endregion
