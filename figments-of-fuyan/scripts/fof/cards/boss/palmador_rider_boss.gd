extends BossCardGD
	
const PALMY_ID: int = 4
	
#region Default
func onProcessAction(action: Action) -> void:
	super(action)
	if !action.post:
		if action is FallDamageAction and action.Card == self:
			action.onFailAction()
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
	onPushAction(BossIntentUsedAction.new(boss_intent, use_type, actions, enemies, allies))

const ROLL_ATTACK_ODDS: float = 0.5
func onChangeBossIntent(boss_intents: Array, enemies: Array, _allies: Array) -> BossIntent:
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
	return boss_intents.pick_random()
	
func onCheckBossIntentCondition(conditional_boss_intent: BossIntent, enemies: Array, allies: Array) -> bool:
	match conditional_boss_intent.name:
		"Rally":
			return onRallyCondition(allies)
		"Summon":
			return onSummonCondition()
		"Spin Attack":
			return onSpinAttackCondition()
		"Reposition":
			return onRepositionCondition()
		"Charge Attack":
			return onChargeAttackCondition(enemies)
		"Jump Attack":
			return onJumpAttackCondition()
	return true
	
func onResetBossIntentCooldowns() -> void:
	super()
	
func onIntentUsed(used_boss_intent: BossIntent, use_type: UseType, actions: Array) -> void:
	super(used_boss_intent, use_type, actions)
	if used_boss_intent.name == "Spin Attack" and use_type == UseType.END and isLevelVisible():
		AniPlayer.play("Spin Attack")
#endregion
	
#region Tile Intents
func setTileIntents() -> void:
	var tile_intents: Array[TileIntentDatastore] = []
	match boss_intent.name:
		"Spin Attack":
			onSpinAttackSetIntents(tile_intents)
		"Rally":
			onRallySetIntents(tile_intents)
		"Jump Attack":
			onJumpAttackSetIntents(tile_intents)
		"Charge Attack":
			onChargeAttackSetIntents(tile_intents)
			
	boss_datastore.setTileIntents(tile_intents)
#endregion
	
#region Spin Attack
const SPIN_ATTACK_SPEED_LIMIT: int = 3
const SPIN_ATTACK_DELAY: float = 1.5
func onSpinAttackSetIntents(tile_intents: Array[TileIntentDatastore]) -> void:
	for _offset: Vector3i in Game.cube_directions:
		var offset: Vector4i = Vector4i(_offset.x, _offset.y, _offset.z, 0)
		var offset_datastore := OffsetDatastore.new(offset, 0, 0, true)
		tile_intents.append(TileIntentDatastore.new(Game.TileIntents.RED, offset_datastore, getCoords()))

func getSpinAttackTiles(CardTile: TileGD = Tile) -> Array:
	return Game.getAdjacentTiles(CardTile, 1)
	
func onSpinAttackCondition() -> bool: # Needs to be on the ground to use
	return getTile().getHeight() == 0
	
func onSpinAttack(enemies: Array, tiles: Array, use_type: UseType) -> Array:
	if use_type != UseType.END:
		tiles = Game.getsetMovementRange(self, SPIN_ATTACK_SPEED_LIMIT)
		if tiles.is_empty(): return []
		
		var BestTile: TileGD
		if !enemies.is_empty():
			var tile_to_adjacent_enemy_count: Dictionary = {}
			for OtherTile: TileGD in tiles:
				var adjacent_enemies: int = enemies.filter(func(x: CardGD): return Game.getCoordsDistance(OtherTile.getCoords(), x.getCoords()) == 1).size()
				tile_to_adjacent_enemy_count[OtherTile] = adjacent_enemies
			
			tiles.sort_custom(func(x: TileGD, y: TileGD): return tile_to_adjacent_enemy_count[x] > tile_to_adjacent_enemy_count[y])
			if tile_to_adjacent_enemy_count[tiles[0]] == 0: # If no adjacent enemies, use tactician logic
				var ally_vision: Array = Game.getTeamVision(0)
				if !ally_vision.is_empty():
					tiles = tiles.filter(func(x: TileGD): return x in ally_vision)
				tiles = getDistantToEnemiesTiles(enemies, tiles)
		else:
			BestTile = tiles.pick_random()
			
		BestTile = tiles[0]
		return [MovementAction.new(self, BestTile.getMovementPathTiles())]
		
	var adjacent_tiles: Array = Game.getAdjacentTiles(Tile)
	var damagables: Array = adjacent_tiles.map(func(x: TileGD): return Game.getFieldCard(x)).filter(func(x: CardGD): return x != null and x.isEnemy(team))
	if damagables.is_empty(): return []
	
	var change_tile_rotation_action := ChangeTileRotationAction.new(self, Game.getRelativeTileRotation(getTile(), damagables.pick_random().getTile()))
	if isLevelVisible():
		change_tile_rotation_action.setActionDelay(SPIN_ATTACK_DELAY)
	
	return [change_tile_rotation_action, DamageAction.new(self, damagables, attack, Game.DamageTypes.ATTACK)]
#endregion

#region Reposition
func onReposition(enemies: Array, tiles: Array, use_type: UseType) -> Array:
	if use_type != UseType.END:
		if tiles.is_empty(): return []
		
		var BestTile: TileGD
		var tiles_adjacent_to_height: Array = []
		if !enemies.is_empty(): # If in combat reposition tries to go up
			for OtherTile: TileGD in tiles:
				for AdjacentTile: TileGD in Game.getAdjacentTiles(OtherTile):
					if AdjacentTile.getHeight() > 0:
						tiles_adjacent_to_height.append(OtherTile)
						break
						
			if tiles_adjacent_to_height.is_empty():
				tiles_adjacent_to_height = tiles.duplicate()
				tiles_adjacent_to_height = getDistantToEnemiesTiles(enemies, tiles_adjacent_to_height)
			else:
				var ally_vision: Array = Game.getTeamVision(0)
				tiles_adjacent_to_height.sort_custom(onTileInVisionSorter.bind(ally_vision))
				tiles_adjacent_to_height\
					.sort_custom(func(x: TileGD, y: TileGD): return Game.getCoordsDistance(x.getCoords(), coords) < Game.getCoordsDistance(y.getCoords(), coords))
		else: tiles_adjacent_to_height = tiles; tiles_adjacent_to_height.shuffle()
		BestTile = tiles_adjacent_to_height[0]
		
		return [MovementAction.new(self, BestTile.getMovementPathTiles())]
	
	if Tile.getHeight() == 0:
		var height_tiles: Array = Game.getAdjacentTiles(Tile).filter(func(x: TileGD): return x.getHeight() > 0)
		if height_tiles.is_empty(): return []
		
		var ally_vision: Array = Game.getTeamVision(0)
		if height_tiles.any(func(x: TileGD): return x in ally_vision):
			height_tiles = height_tiles.filter(func(x: TileGD): return x in ally_vision)
			
		var BestTile: TileGD = height_tiles.pick_random()
		return [MovementAction.new(self, [getTile(), BestTile]), ChangeTileRotationAction.new(self, Game.getRelativeTileRotation(Tile, BestTile))]
	return []
	
func onRepositionCondition() -> bool:
	return getTile().getHeight() == 0
	
func onTileInVisionSorter(x: TileGD, y: TileGD, ally_vision: Array) -> int:
	var first_in_vision: bool = x in ally_vision
	var second_in_vision: bool = y in ally_vision
	if first_in_vision and second_in_vision:
		return 0
	elif first_in_vision:
		return -1
	return 1
		
#endregion

#region Rally
const RALLY_MINIMUM_PALMY_AMOUNT: int = 2
const RALLY_SPEED_LIMIT: int = 2
func onRallyCondition(allies: Array) -> bool:
	return allies.filter(func(x: CardGD): return x.info.id == PALMY_ID).size() >= RALLY_MINIMUM_PALMY_AMOUNT
	
func onRallySetIntents(tile_intents: Array[TileIntentDatastore]) -> void:
	for Card: CardGD in Game.getAllyUnits(team):
		tile_intents.append(TileIntentDatastore.new(Game.TileIntents.GREEN, OffsetDatastore.new(), Card.getTile().getCoords()))
		
func onRally(enemies: Array, allies: Array, tiles: Array, use_type: UseType) -> Array:
	var actions: Array = []
	if use_type == UseType.START:
		actions.append(StatAction.new(allies.filter(func(x: CardGD): return x.info.id == PALMY_ID)\
			.map(func(x: CardGD): return StatInfo.new(x, Game.Stats.ATTACK, 1, 2))))
			
		var ally_vision: Array = Game.getTeamVision(0)
		tiles = Game.getsetMovementRange(self, RALLY_SPEED_LIMIT)
		
		if !ally_vision.is_empty():
			tiles = tiles.filter(func(x: TileGD): return x in ally_vision)
			
		tiles = onRemoveGroundTilesWhenOnGround(tiles)
		tiles = getDistantToEnemiesTiles(enemies, tiles)
		
		if !tiles.is_empty():
			var BestTile: TileGD = tiles[0]
			actions.append(MovementAction.new(self, BestTile.getMovementPathTiles()))
	return actions
#endregion

#region Summon
const MAX_PALMY_AMOUNT_ON_MAP: int = 10
const SUMMON_SPEED_LIMIT: int = 2
func onSummonCondition() -> bool:
	return Game.getAllyUnits(1).filter(func(x: CardGD): return x.info.id == PALMY_ID).size() <= MAX_PALMY_AMOUNT_ON_MAP

func onSummon(enemies: Array, tiles: Array, use_type: UseType) -> Array:
	var actions: Array = []
	if use_type == UseType.START:
		tiles = tiles.filter(func(x: TileGD): return Game.getFieldCard(x) == null)
		tiles = onRemoveHighTiles(tiles) # Removes from being able to spawn palmy's up high
		tiles.shuffle()
		
		var chosen_tiles: Array = []
		if !tiles.is_empty(): chosen_tiles.append(tiles.pop_front())
		if !tiles.is_empty(): chosen_tiles.append(tiles.pop_front())
		
		actions += chosen_tiles.map(func(x: TileGD): return AwakenAction.new(Game.getNewFieldCard(PALMY_ID, x, team, 0, false, true), x))
		
		var ally_vision: Array = Game.getTeamVision(0)
		tiles = Game.getsetMovementRange(self, SUMMON_SPEED_LIMIT)
		
		if !ally_vision.is_empty():
			tiles = tiles.filter(func(x: TileGD): return x in ally_vision)
			
		tiles = onRemoveGroundTilesWhenOnGround(tiles)
		tiles = getDistantToEnemiesTiles(enemies, tiles)
		
		if !tiles.is_empty():
			var BestTile: TileGD = tiles[0]
			actions.append(MovementAction.new(self, BestTile.getMovementPathTiles()))
	return actions
#endregion

#region Jump Attack
const ADJACENT_DAMAGE: int = 2
const DOUBLE_ADJACENT_DAMAGE: int = 1
func onJumpAttackSetIntents(tile_intents: Array[TileIntentDatastore]) -> void:
	var enemies: Array = getVisibleFieldCardsEnemies()
	var CenterTile: TileGD
	
	if !enemies.is_empty():
		CenterTile = enemies.pick_random().getTile()
	else:
		var tiles: Array = getVisibleTiles()
		tiles = onRemoveHighTiles(tiles)
		CenterTile = tiles.pick_random()
	
	boss_datastore.setBossIntentTiles({CenterTile: null})
	tile_intents.append(TileIntentDatastore.new(Game.TileIntents.DARK_RED, null, CenterTile.getCoords()))
	for AdjacentTile in Game.getAdjacentTiles(CenterTile, 1):
		tile_intents.append(TileIntentDatastore.new(Game.TileIntents.RED, null, AdjacentTile.getCoords()))
	
	for DoubleAdjacentTile in Game.getAdjacentTiles(CenterTile, 2):
		tile_intents.append(TileIntentDatastore.new(Game.TileIntents.LIGHT_RED, null, DoubleAdjacentTile.getCoords()))
		
func onJumpAttack(use_type: UseType) -> Array:
	var actions: Array = []
	if use_type == UseType.START:
		var CenterTile: TileGD = boss_datastore.getBossIntentTiles()[0]
		var EnemyCenterCard: CardGD = Game.getFieldCard(CenterTile)
		if EnemyCenterCard != null:
			actions.append(DestroyAction.new(EnemyCenterCard, self))
		actions.append(MoveToTileAction.new(self, CenterTile))
		
	elif use_type == UseType.END:
		var CenterTile: TileGD = boss_datastore.getBossIntentTiles()[0]
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
	
func onJumpAttackCondition() -> bool:
	return getTile().getHeight() > 0
#endregion

#region Charge Attack
const MAX_CHARGE_DISTANCE: int = 4
func onChargeAttackCondition(enemies: Array) -> bool:
	if getTile().getHeight() > 0: return false
	
	var wall_adjacent_origin_tiles: Array = []
	for diagonal in Game.cube_directions:
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
					wall_adjacent_origin_tiles.append(DiagonalTile)
				break
			
	if wall_adjacent_origin_tiles.is_empty(): return false # If nothing found
	enemies = Game.getEnemyUnits(team)
	var enemy_tiles: Array = enemies.map(func(x: CardGD): return x.getTile())
	for OriginWallTile: TileGD in wall_adjacent_origin_tiles:
		for AdjacentTile: TileGD in getWallAdjacentTiles(OriginWallTile, 1):
			if AdjacentTile in enemy_tiles:
				return true
	return false
	
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
	var height_tiles: Array = Game.getAdjacentTiles(PointTile).filter(func(x: TileGD): return x.getHeight() > 0 and x not in wall_tiles.keys())
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
		for AdjacentTile: TileGD in Game.getAdjacentOrCloserTiles(WallTile, distance).filter(func(x: TileGD): return x.getHeight() == 0):
			wall_adjacent_tiles[AdjacentTile] = null
	return wall_adjacent_tiles.keys()
	
func onChargeAttackSetIntents(tile_intents: Array) -> void:
	var directions: Array = Game.cube_directions.duplicate()
	directions.shuffle()
	
	var tile_to_type: Dictionary = getChargeIntentTiles(directions)
	tile_to_type[getTile()] = "" # So it doesn't show any intent
	
	for IntentTile: TileGD in tile_to_type:
		match tile_to_type[IntentTile]:
			"DiagonalTile":
				tile_intents.append(TileIntentDatastore.new(Game.TileIntents.DARK_RED, null, IntentTile.getCoords()))
			"ChargeEndTile":
				tile_intents.append(TileIntentDatastore.new(Game.TileIntents.DARK_RED, null, IntentTile.getCoords()))
				boss_datastore.setBossIntentTiles({IntentTile: null})
			"WallAdjacentTile":
				tile_intents.append(TileIntentDatastore.new(Game.TileIntents.RED, null, IntentTile.getCoords()))
	
func onChargeAttack(use_type: UseType) -> Array:
	var actions: Array = []
	var ChargeEndTile: TileGD = boss_datastore.getBossIntentTiles()[0]
	if use_type == UseType.START:
		if ChargeEndTile == getTile(): return []
		var enemies_on_path: Array = ChargeEndTile.getMovementPathTiles().map(func(x: TileGD): return Game.getFieldCard(x))\
			.filter(func(x: CardGD): return x != null and isEnemy(team))
		
		actions += enemies_on_path.map(func(x: CardGD): return DestroyAction.new(x))
		actions.append(MovementAction.new(self, ChargeEndTile.getMovementPathTiles()))
	elif use_type == UseType.END:
		var wall_adjacent_tiles: Array = getWallAdjacentTiles(ChargeEndTile, 2)
		var enemies: Array = Game.getEnemyUnits(team).filter(func(x: CardGD): return x.getTile() in wall_adjacent_tiles)
		actions.append(DamageAction.new(self, enemies, 2, Game.DamageTypes.OTHER))
	
	return actions
#endregion

#region Helper
func getDistantToEnemiesTiles(enemies: Array, tiles: Array) -> Array:
	tiles = tiles.duplicate()
	var tiles_to_distance: Dictionary = {}
	for OtherTile: TileGD in tiles:
		var distance: int = enemies.map(func(x: CardGD): return Game.getCoordsDistance(x.getCoords(), Tile.getCoords())).min()
		tiles_to_distance[OtherTile] = distance
			
	tiles.sort_custom(func(x: TileGD, y: TileGD): return tiles_to_distance[x] > tiles_to_distance[y])
	return tiles
	
func getCloseToEnemiesTiles(enemies: Array, tiles: Array) -> Array:
	tiles = tiles.duplicate()
	var tiles_to_distance: Dictionary = {}
	for OtherTile: TileGD in tiles:
		var distance: int = enemies.map(func(x: CardGD): return Game.getCoordsDistance(x.getCoords(), Tile.getCoords())).min()
		tiles_to_distance[OtherTile] = distance
			
	tiles.sort_custom(func(x: TileGD, y: TileGD): return tiles_to_distance[x] < tiles_to_distance[y])
	return tiles
	
func onRemoveHighTiles(tiles: Array) -> Array:
	if getTile().getHeight() > 0:
		return tiles.filter(func(x: TileGD): return x.getHeight() == 0)
	return tiles

func onRemoveGroundTilesWhenOnGround(tiles: Array) -> Array:
	if getTile().getHeight() > 0:
		return tiles.filter(func(x: TileGD): return x.getHeight() > 0)
	return tiles
#endregion
