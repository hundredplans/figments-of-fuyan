extends BossCardGD
	
const PALMY_ID: int = 4
var diagonal_center_coords: Array = []
	
#region Default
func onProcessAction(action: Action) -> void:
	super(action)
	if !action.post:
		if action is FallDamageAction and action.Card == self:
			action.onFailAction()
			
func onLoadDataLevel() -> void:
	super()
	onPreloadDiagonalCenterCoords()
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
			
	if use_type == UseType.START:
		actions.append(ChangeTurnStateAction.new(self, Game.TurnStates.ACTIVE))
			
	if use_type == UseType.END:
		boss_datastore.boss_intent_used_this_turn = true
		actions.append(BossIntentFinishedAction.new(self))
		
	elif actions.is_empty() or !actions.any(func(x: Action): return x is MovementAction):
		var movement_finish_action := MovementFinishAction.new(self, tiles, allies, enemies)
		actions.append(movement_finish_action)
		
	onPushAction(actions)

const ROLL_ATTACK_ODDS: float = 0.5
func onChangeBossIntent(boss_intents: Array, enemies: Array, _allies: Array) -> BossIntent:
	if !enemies.is_empty():
		if Random.rollFloat(ROLL_ATTACK_ODDS):
			boss_intents = boss_intents.filter(func(x: BossIntent): return x.type in [x.IntentType.ATTACK, x.IntentType.MOVEMENT_ATTACK])
		else:
			boss_intents = boss_intents.filter(func(x: BossIntent): return x.type not in [x.IntentType.ATTACK, x.IntentType.MOVEMENT_ATTACK])
			if boss_intents.is_empty(): # If he repositions into a reposition
				boss_intents = boss_intents.filter(func(x: BossIntent): return x.type in [x.IntentType.ATTACK, x.IntentType.MOVEMENT_ATTACK])
	else:
		boss_intents = boss_intents.filter(func(x: BossIntent): return x.name in ["Spin Attack", "Reposition"])
	return boss_intents.pick_random()
	
func onCheckBossIntentCondition(boss_intent: BossIntent, enemies: Array, allies: Array) -> bool:
	match boss_intent.name:
		"Rally":
			return onRallyCondition(allies)
		"Summon":
			return onSummonCondition()
		"Charge Attack":
			return onChargeAttackCondition(enemies)
	return true
	
func onResetBossIntentCooldowns() -> void:
	super()
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
func onSpinAttackSetIntents(tile_intents: Array[TileIntentDatastore]) -> void:
	for _offset: Vector3i in Game.cube_directions:
		var offset: Vector4i = Vector4i(_offset.x, _offset.y, _offset.z, 0)
		var offset_datastore := OffsetDatastore.new(offset, 0, 0, true)
		tile_intents.append(TileIntentDatastore.new(Game.TileIntents.RED, offset_datastore, getCoords()))

func getSpinAttackTiles(CardTile: TileGD = Tile) -> Array:
	return Game.getAdjacentTiles(CardTile, 1)
	
func onSpinAttack(enemies: Array, tiles: Array, use_type: UseType) -> Array:
	if use_type != UseType.END:
		tiles = Game.getsetMovementRange(self, SPIN_ATTACK_SPEED_LIMIT)
		tiles = onRemoveHighTiles(tiles)
		if tiles.is_empty(): return []
		
		var BestTile: TileGD
		if !enemies.is_empty():
			var tile_to_adjacent_enemy_count: Dictionary = {}
			for OtherTile: TileGD in tiles:
				var adjacent_enemies: int = enemies.filter(func(x: CardGD): return Game.getCoordsDistance(OtherTile.getCoords(), x.getCoords()) == 1).size()
				tile_to_adjacent_enemy_count[OtherTile] = adjacent_enemies
			
			tiles.sort_custom(func(x: TileGD, y: TileGD): return tile_to_adjacent_enemy_count[x] > tile_to_adjacent_enemy_count[y])
			if tile_to_adjacent_enemy_count[tiles[0]] == 0:
				var diagonal_tiles: Array = getDiagonalTiles(tiles)
				if !diagonal_tiles.is_empty(): tiles = diagonal_tiles
			
		else:
			var diagonal_tiles: Array = getDiagonalTiles(tiles)
			if !diagonal_tiles.is_empty(): tiles = diagonal_tiles
			var tile_to_distance: Dictionary = {}
			for OtherTile: TileGD in tiles:
				tile_to_distance[OtherTile] = Game.getCoordsDistance(Tile.getCoords(), OtherTile.getCoords())
				
			tiles.sort_custom(func(x: TileGD, y: TileGD): return tile_to_distance[x] > tile_to_distance[y])
			
		BestTile = tiles[0]
		return [MovementAction.new(self, BestTile.getMovementPathTiles())]
	var adjacent_tiles: Array = Game.getAdjacentTiles(Tile)
	var damagables: Array = adjacent_tiles.map(func(x: TileGD): return Game.getFieldCard(x)).filter(func(x: CardGD): return x != null and x.isEnemy(team))
	
	return [ChangeTileRotationAction.new(self, Game.getRelativeTileRotation(getTile(), damagables.pick_random().getTile())),\
		DamageAction.new(self, damagables, attack, Game.DamageTypes.ATTACK)] if !damagables.is_empty() else []
#endregion

#region Reposition
func onReposition(enemies: Array, tiles: Array, use_type: UseType) -> Array:
	if use_type != UseType.END:
		if tiles.is_empty(): return []
		tiles = onRemoveHighTiles(tiles)
		
		var BestTile: TileGD
		var tiles_adjacent_to_height: Array = []
		if !enemies.is_empty():
			for OtherTile: TileGD in tiles:
				for AdjacentTile: TileGD in Game.getAdjacentTiles(OtherTile):
					if AdjacentTile.getHeight() > 0:
						tiles_adjacent_to_height.append(OtherTile)
						break
					
		if tiles_adjacent_to_height.is_empty():
			tiles_adjacent_to_height = tiles.duplicate()
		var tiles_to_distance: Dictionary = {}
		
		if !enemies.is_empty():
			var ally_vision: Array = Game.getTeamVision(0)
			tiles_adjacent_to_height = tiles_adjacent_to_height.filter(func(x: TileGD): return x in ally_vision)
			tiles_adjacent_to_height = getDistantToEnemiesTiles(enemies, tiles_adjacent_to_height)
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
		actions += allies.filter(func(x: CardGD): return x.info.id == PALMY_ID)\
			.map(func(x: CardGD): return StatInfo.new(x, Game.Stats.ATTACK, 1, 2))
		
		tiles = Game.getsetMovementRange(self, RALLY_SPEED_LIMIT)
		tiles = onRemoveHighTiles(tiles)
		
		var diagonal_tiles: Array = getDiagonalTiles(tiles)
		if !diagonal_tiles.is_empty(): tiles = diagonal_tiles
		tiles = getDistantToEnemiesTiles(enemies, tiles)
		
		if !tiles.is_empty():
			var BestTile: TileGD = tiles[0]
			actions.append(MovementAction.new(self, BestTile.getMovementPathTiles()))
	return actions
#endregion

#region Summon
const SUMMON_MAXIMUM_PALMY_AMOUNT: int = 1
const SUMMON_SPEED_LIMIT: int = 2
func onSummonCondition() -> bool:
	return Game.getAllyUnits(1).filter(func(x: CardGD): return x.info.id == PALMY_ID).size() <= SUMMON_MAXIMUM_PALMY_AMOUNT

func onSummon(enemies: Array, tiles: Array, use_type: UseType) -> Array:
	var actions: Array = []
	if use_type == UseType.START:
		tiles = tiles.filter(func(x: TileGD): return Game.getFieldCard(x) == null)
		tiles.shuffle()
		
		var chosen_tiles: Array = []
		if !tiles.is_empty(): chosen_tiles.append(tiles.pop_front())
		if !tiles.is_empty(): chosen_tiles.append(tiles.pop_front())
		
		actions += chosen_tiles.map(func(x: TileGD): return AwakenAction.new(Game.getNewFieldCard(PALMY_ID, x, team, 0, false, true), x))
		
		tiles = Game.getsetMovementRange(self, SUMMON_SPEED_LIMIT)
		tiles = onRemoveHighTiles(tiles)
		
		var diagonal_tiles: Array = getDiagonalTiles(tiles)
		if !diagonal_tiles.is_empty(): tiles = diagonal_tiles
		
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
	var BestEnemy: CardGD = enemies.pick_random()
	var CenterTile: TileGD = BestEnemy.getTile()
	
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
#endregion

#region Charge Attack
const CHARGE_ATTACK_MAX_DISTANCE: int = 7
func onChargeAttackCondition(enemies: Array) -> bool:
	if getTile().getHeight() > 0: return false
	
	var diagonal: Vector4i = getDiagonal()
	if diagonal == Vector4i.ZERO: return false
		
	var enemy_coords: Array = enemies.map(func(x: CardGD): return x.getTile().getCoords())
	for diag in [diagonal, diagonal * -1]: # Has to search backward and forward
		for i in range(1, CHARGE_ATTACK_MAX_DISTANCE + 1):
			if (diag * i) in enemy_coords:
				return true
	return false

func onChargeAttackSetIntents(tile_intents: Array) -> void:
	var enemies: Array = getVisibleFieldCardsEnemies()
	var enemy_tiles: Array = enemies.map(func(x: CardGD): return x.getTile())
	var enemy_coords: Array = enemy_tiles.map(func(x: TileGD): return x.getCoords())
	var diagonal: Vector4i = getDiagonal()
	
	var coords: Vector4i = getCoords()
	var diagonals: Array = [diagonal, diagonal * -1]
	diagonals.shuffle()
	for diag in diagonals: # Has to search backward and forward
		if isViableDiagonal(diag, enemy_coords):
			var left_diag := Game.onRotateCoordsCC(1, diag)
			var right_diag := Game.onRotateCoordsClockwise(1, diag)
			
			for i in range(1, CHARGE_ATTACK_MAX_DISTANCE + 1):
				var CenterTile: TileGD = Game.getTile((diag * i) + coords)
				if CenterTile != null and (CenterTile.isOccupied() or CenterTile.isSolid()):
					boss_datastore.setBossIntentTiles({CenterTile: null})
					return
					
				if CenterTile == null:
					boss_datastore.setBossIntentTiles({Game.getTile(diag * (i - 1)): null})
					return
					
				var LeftTile: TileGD = Game.getTile((left_diag * i) + coords)
				var RightTile: TileGD = Game.getTile((right_diag * i) + coords)
				
				if LeftTile != null:
					tile_intents.append(TileIntentDatastore.new(Game.TileIntents.RED, null, LeftTile.getCoords()))
					
				if RightTile != null:
					tile_intents.append(TileIntentDatastore.new(Game.TileIntents.RED, null, RightTile.getCoords()))
					
				if CenterTile != null:
					tile_intents.append(TileIntentDatastore.new(Game.TileIntents.RED, null, CenterTile.getCoords()))
			
			var CenterTile: TileGD = Game.getTile(diag * CHARGE_ATTACK_MAX_DISTANCE)
			boss_datastore.setBossIntentTiles({CenterTile: null})
			return
	
func isViableDiagonal(diag: Vector4i, enemy_coords: Array) -> bool:
	var coords: Vector4i = getCoords()
	var left_diag := Game.onRotateCoordsCC(1, diag)
	var right_diag := Game.onRotateCoordsClockwise(1, diag)
	
	for i in range(1, CHARGE_ATTACK_MAX_DISTANCE + 1):
		var distance_diag: Vector4i = (diag * i) + coords
		var distance_left_diag: Vector4i = (left_diag * i) + coords
		var distance_right_diag: Vector4i = (right_diag * i) + coords
		
		if distance_diag in enemy_coords or distance_left_diag in enemy_coords or distance_right_diag in enemy_coords:
			return true
	return false
	
func onChargeAttack(use_typea: UseType) -> Array:
	return []
	
func getDiagonal() -> Vector4i:
	return coords if (coords in diagonal_center_coords) else Vector4i.ZERO
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
	
func onRemoveHighTiles(tiles: Array) -> Array:
	if getTile().getHeight() > 0:
		return tiles.filter(func(x: TileGD): return x.getHeight() == 0)
	return tiles
	
func getDiagonalTiles(tiles: Array) -> Array:
	return tiles.filter(func(x: TileGD): return x.getCoords() in diagonal_center_coords)
	
func onPreloadDiagonalCenterCoords() -> void:
	for _offset: Vector3i in Game.cube_directions:
		var offset := Vector4i(_offset.x, _offset.y, _offset.z, 0)
		for i in range(1, 10):
			diagonal_center_coords.append(offset * i)
#endregion
