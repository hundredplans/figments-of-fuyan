extends EpicCardGD

const SILAS_STARE_ENEMY_AMOUNT_CONDITION: int = 2
const SPINNING_SWORD_START_TURNS: int = 6
const AUTOATTACK_PHASE_ONE_SPEED_LIMIT: int = 2
const SPIN_ATTACK_ACTION_DELAY: float = 2.0
const DEFENSIVE_STANCE_ACTION_DELAY: float = 2.0
const DEFENSIVE_STANCE_ARMOUR_AMOUNT: int = 1
const DEFENSIVE_STANCE_ARMOR_TURNS: int = 3
const LONG_SLASH_PHASE_ONE_RANGE: int = 4
const LONG_SLASH_PHASE_TWO_RANGE: int = 5
const LONG_SLASH_SPEED_LIMIT: int = 1
const LONG_SLASH_ACTION_DELAY: float = 1.2
const GRAND_SLASH_ACTION_DELAY: float = 2.1
const SPINNING_SWORD_VFX_ID: int = 2
const JUMP_ATTACK_DISTANCE: int = 4
const ARMOR_TRAIT_ID: int = 1
const FIRST_PHASE_CHANGE_HEALTH: int = 14
const SPINNING_SWORD_ACTION_DELAY: float = 2.4

var spinning_sword_public_id: int
var spinning_sword_turns: int
var active_speed: int

#region Default
func onProcessAction(action: Action) -> void:
	super(action)
	if isValidEndOfTurn(action) and spinning_sword_turns > 0:
		onSpinningSwordLowerTurns()
	elif getPhase() == 2 and isValidRampage(action):
		onRampagePassive()
		
	if action.post:
		if action is MoveToTileAction and action.Card == self:
			active_speed = max(active_speed - 1, 0)
		elif action is VisionNewUnitAction and action.Discoverer == self and\
		action.Discovered.isEnemy(team) and boss_intent != null and boss_intent.name == "SilasStare":
			onVisionNewUnitUpdateSilasStare(action.Discovered, action.enter_vision)
		elif action is StatAction and action.hasCard(self) and\
			(health <= FIRST_PHASE_CHANGE_HEALTH and getPhase() == 1):
				onPushAction(ChangeBossPhaseAction.new())
		elif action is AddFieldEffectAction and action.getCard() == self and action.getFieldEffectId() == SHIELD_ID:
			onPushAction(AnimationModifierAction.new(self, "Hurt", "Parry"))
		elif action is RemoveFieldEffectAction and action.getCard() == self and action.getFieldEffectId() == SHIELD_ID:
			onPushAction(AnimationModifierAction.new(self, "Hurt", ""))
		
func onSave() -> SavedDataEpicCard:
	ability_save['spinning_sword_turns'] = spinning_sword_turns
	ability_save['active_speed'] = active_speed
	ability_save['spinning_sword_public_id'] = spinning_sword_public_id
	return super()

func onLoadDataLevel() -> void:
	super()
	if spinning_sword_public_id > 0:
		var SpinningSword: VFXGD = SavedData.onLoadModel(SavedDataVFX.new(SPINNING_SWORD_VFX_ID, true), self)
		spinning_sword_public_id = SpinningSword.public_id
		onPushAction(CreateVFXAction.new(SpinningSword, false))

func onUseBossIntent(enemies: Array, allies: Array, tiles: Array, use_type: UseType) -> void:
	var actions: Array = []
	match boss_intent.name:
		"SilasStare": actions = onSilasStare(use_type)
		"Reposition": actions = onReposition(enemies, tiles, use_type)
		"Autoattack": actions = onAutoattack(enemies, allies, tiles, use_type)
		"SpinningSword": actions = onSpinningSword(use_type)
		"SpinAttack": actions = onSpinAttack(use_type)
		"DefensiveStance": actions = onDefensiveStance(use_type)
		"JumpAttack": actions = onJumpAttack(enemies, tiles, use_type)
		"GrandSlash": actions = onGrandSlash(enemies, tiles, use_type)
		"LongSlash": actions = onLongSlash(enemies, tiles, use_type)
	onPushAction(BossIntentUsedAction.new(boss_intent, use_type, actions, enemies, allies))
	
func onChangeBossIntent(boss_intents: Array, _enemies: Array, _allies: Array) -> BossIntent:
	if boss_intent.name == "Reposition":
		return getBossIntentByName("SpinAttack")
		
	boss_intents = onRemoveName(boss_intents, "SpinAttack")
	if boss_intents.is_empty():
		return getBossIntentByName("Reposition")
		
	return boss_intents.pick_random()
	
func onCheckBossIntentCondition(conditional_boss_intent: BossIntent, _enemies: Array, _allies: Array) -> bool:
	var condition_result: BossIntentConditionResult
	match conditional_boss_intent.name:
		"SilasStare": condition_result = onSilasStareCondition()
		"DefensiveStance": condition_result = onDefensiveStanceCondition()
		"GrandSlash": condition_result = onGrandSlashCondition()
		"JumpAttack": condition_result = onJumpAttackCondition()
		_: condition_result = BossIntentConditionResult.new(true)
	boss_datastore.setConditionResult(condition_result, conditional_boss_intent.name)
	return condition_result.state
#endregion

#region SilasStare
func onSilasStareSetIntents() -> BossTileIntents:
	var tile_intents: Array[TileIntentDatastore] = []
	for EnemyCard: CardGD in getVisibleFieldCardsEnemies():
		tile_intents.append(TileIntentDatastore.new(Game.TileIntents.PURPLE, OffsetDatastore.new(), EnemyCard.getCoords()))
	return BossTileIntents.new(tile_intents, {})

func onSilasStare(use_type: UseType) -> Array:
	var actions: Array = []
	if use_type == UseType.START:
		for EnemyCard: CardGD in getVisibleFieldCardsEnemies():
			actions.append(StatAction.new(StatInfo.new(EnemyCard, Game.Stats.MAX_SPEED, -1, 1)))
	return actions
	
func onSilasStareCondition() -> BossIntentConditionResult:
	return BossIntentConditionResult.new(\
		getVisibleFieldCardsEnemies().size() >= SILAS_STARE_ENEMY_AMOUNT_CONDITION)
		
func onVisionNewUnitUpdateSilasStare(NewUnit: CardGD, enter_vision: bool) -> void:
	var tile_intents: Array[TileIntentDatastore] = boss_datastore.getTileIntents().duplicate()
	if !enter_vision:
		tile_intents = tile_intents.filter(func(x: TileIntentDatastore): return x.getCoords() != NewUnit.getCoords())
	else:
		tile_intents.append(TileIntentDatastore.new(Game.TileIntents.PURPLE, OffsetDatastore.new(), NewUnit.getCoords()))
	boss_datastore.onFirstUpdateTileIntents(tile_intents)
#endregion

#region SpinningSword
func onSpinningSwordSetIntents() -> BossTileIntents:
	var tile_intents: Array[TileIntentDatastore] = []
	tile_intents.append(TileIntentDatastore.new(Game.TileIntents.GREEN, OffsetDatastore.new(), coords))
	return BossTileIntents.new(tile_intents, {})
	
func onSpinningSword(use_type: UseType) -> Array:
	if use_type == UseType.START:
		spinning_sword_turns = SPINNING_SWORD_START_TURNS
		var SpinningSword: VFXGD = SavedData.onLoadModel(SavedDataVFX.new(SPINNING_SWORD_VFX_ID, true), self)
		spinning_sword_public_id = SpinningSword.public_id
		
		var animation_action := AnimationAction.new(self, "SpinningSword")
		animation_action.setActionDelay(SPINNING_SWORD_ACTION_DELAY)
		
		return [CreateVFXAction.new(SpinningSword, false)]
	return []
	
func isSpinningSword() -> bool:
	return spinning_sword_turns > 1 or getPhase() == 2
	
func onSpinningSwordLowerTurns() -> void:
	spinning_sword_turns = max(spinning_sword_turns - 1, 0)
	if spinning_sword_turns == 0:
		onDestroySpinningSwordVFX()
		
func onDestroySpinningSwordVFX(is_force: bool = false) -> void:
	spinning_sword_turns = -1
	var SpinningSword: VFXGD = Game.onFindPublicIDObject(spinning_sword_public_id)
	if SpinningSword == null: return
	
	var destroy_vfx_action := DestroyVFXAction.new(SpinningSword)
	if is_force: onForceAction(destroy_vfx_action)
	else: onPushAction(destroy_vfx_action)
#endregion

#region Reposition
func onRepositionSetIntents() -> BossTileIntents: return BossTileIntents.new()

func onReposition(enemies: Array, tiles: Array, use_type: UseType) -> Array:
	if use_type != UseType.END:
		tiles = getUnoccupiedTiles(tiles)
		tiles = getCloseToEnemiesTiles(enemies, tiles)
		if tiles.is_empty(): return []
		
		var BestTile: TileGD = tiles[0]
		return [MovementAction.new(self, BestTile.getMovementPathTiles())]
	return []
#endregion

#region Autoattack
func onAutoattackSetIntents() -> BossTileIntents:
	var tile_intents: Array[TileIntentDatastore] = []
	var tile_color := Game.TileIntents.RED if getPhase() == 1 else Game.TileIntents.DARK_RED
	
	if !isSpinningSword():
		var direction := Game.getCubeDirectionExtra(0)
		tile_intents.append(TileIntentDatastore.new(tile_color,\
			OffsetDatastore.new(direction, true, tile_rotation), coords))
	else:
		for x: Vector4i in Game.getCubeDirectionsExtra():
			tile_intents.append(TileIntentDatastore.new(tile_color, OffsetDatastore.new(x, true), coords))
	return BossTileIntents.new(tile_intents, {})

func onAutoattack(enemies: Array, allies: Array, tiles: Array, use_type: UseType) -> Array:
	var actions: Array = []
	if use_type == UseType.START and getPhase() == 1:
		active_speed = AUTOATTACK_PHASE_ONE_SPEED_LIMIT
		
	if use_type != UseType.END:
		if getPhase() == 1: tiles = getsetMovementRange(active_speed)
		
		if tiles.is_empty(): return []
		if use_type == UseType.END: return []
		if enemies.is_empty(): return [MovementAction.new(self, tiles.pick_random().getMovementPathTiles())]
		
		var DFL := DefaultFightLogic.new(self, tiles, enemies, allies)
		var path: Array = DFL.getKillPath()
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
	elif isSpinningSword():
		var adjacent_enemies: Array = Game.getEnemyUnits(team).filter(func(x: CardGD): return Game.isAdjacent(x.getTile(), getTile()))
		adjacent_enemies = adjacent_enemies\
			.filter(func(x: CardGD): return Game.getTile(coords + Game.getCubeDirectionExtra(tile_rotation)) == x.getTile())
		actions.append(DamageAction.new(self, adjacent_enemies, attack, Game.DamageTypes.OTHER))
	return actions
#endregion Autoattack

#region Spin Attack
func onSpinAttackSetIntents() -> BossTileIntents:
	var tile_intents: Array[TileIntentDatastore] = []
	var adjacent_tiles: Array = Game.getAdjacentTiles(Tile, 1)
	var double_adjacent_tiles: Array = Game.getAdjacentTiles(Tile, 2)
	var triple_adjacent_tiles: Array = Game.getAdjacentTiles(Tile, 3)
	
	var adjacent_color := Game.TileIntents.RED if getPhase() == 1 else Game.TileIntents.DARK_RED
	for OtherTile: TileGD in adjacent_tiles:
		tile_intents.append(TileIntentDatastore.new(adjacent_color, null, OtherTile.getCoords()))
		
	var double_adjacent_color := Game.TileIntents.RED if getPhase() == 1 else Game.TileIntents.DARK_RED
	for OtherTile: TileGD in double_adjacent_tiles:
		tile_intents.append(TileIntentDatastore.new(double_adjacent_color, null, OtherTile.getCoords()))

	var triple_adjacent_color := Game.TileIntents.LIGHT_RED if getPhase() == 1 else Game.TileIntents.DARK_RED
	for OtherTile: TileGD in triple_adjacent_tiles:
		tile_intents.append(TileIntentDatastore.new(triple_adjacent_color, null, OtherTile.getCoords()))
	return BossTileIntents.new(tile_intents, {})
	
func onSpinAttack(use_type: UseType) -> Array:
	var actions: Array = []
	if use_type == UseType.START:
		var all_enemies: Array = Game.getEnemyUnits(team)
		var adjacent_enemies: Array = all_enemies.filter(func(x: CardGD): return Game.getCoordsDistance(x.getCoords(), coords) == 1)
		var double_adjacent_enemies: Array = all_enemies.filter(func(x: CardGD): return Game.getCoordsDistance(x.getCoords(), coords) == 2)
		var triple_adjacent_enemies: Array = all_enemies.filter(func(x: CardGD): return Game.getCoordsDistance(x.getCoords(), coords) == 3)
		
		var animation_action := AnimationAction.new(self, "SpinAttack")
		animation_action.setActionDelay(SPIN_ATTACK_ACTION_DELAY)
		actions.append(animation_action)
		
		actions.append(DamageAction.new(self, adjacent_enemies, attack, Game.DamageTypes.OTHER))
		actions.append(DamageAction.new(self, double_adjacent_enemies, attack, Game.DamageTypes.OTHER))
		
		var triple_adjacent_damage: int = (attack - 1) if getPhase() == 1 else attack
		actions.append(DamageAction.new(self, triple_adjacent_enemies, triple_adjacent_damage, Game.DamageTypes.OTHER))
		actions.append(ClearTileIntentsAction.new())
	return actions
#endregion

#region DefensiveStance
func onDefensiveStanceSetIntents() -> BossTileIntents:
	var tile_intents: Array[TileIntentDatastore] = []
	tile_intents.append(TileIntentDatastore.new(Game.TileIntents.GREEN, OffsetDatastore.new(), coords))
	return BossTileIntents.new(tile_intents, {})
	
func onDefensiveStance(use_type: UseType) -> Array:
	var actions: Array = []
	if use_type == UseType.START:
		var animation_action := AnimationAction.new(self, "DefensiveStance")
		animation_action.setActionDelay(DEFENSIVE_STANCE_ACTION_DELAY)
		actions.append(animation_action)
		
		actions.append(onGainShieldAction())
		if getPhase() == 2:
			var armor_trait_data := SavedDataTrait.new(ARMOR_TRAIT_ID, true, 0, DEFENSIVE_STANCE_ARMOUR_AMOUNT)
			var armor_overworld := OverworldTrait.new(armor_trait_data, OverworldTrait.AddedBy.ELDER_PALMER, true, DEFENSIVE_STANCE_ARMOR_TURNS)
			actions.append(AddOverworldTraitAction.new(self, armor_overworld, true))
	return actions
	
func onDefensiveStanceCondition() -> BossIntentConditionResult:
	return BossIntentConditionResult.new(getFirstFieldEffect(SHIELD_ID) == null)
#endregion

#region GrandSlash
func onGrandSlashSetIntents() -> BossTileIntents:
	var tile_intents: Array[TileIntentDatastore] = []
	var slash_tile_rotation: int = boss_datastore.getConditionResult("GrandSlash").getTileRotation()
	var direction := Game.getCubeDirectionExtra(slash_tile_rotation)
	var left_direction := Game.getCubeDirectionExtra((slash_tile_rotation - 2) % 6)
	var right_direction := Game.getCubeDirectionExtra((slash_tile_rotation + 2) % 6)
	var tile_results: Dictionary[TileGD, String] = {}
	
	for i: int in range(1, 6):
		var forward_coords: Vector4i = (direction * i)
		var side_amount: int = 2 if i == 1 else 3
		for j: int in range(1, side_amount + 1):
			var left_side_coords: Vector4i = forward_coords + (left_direction * j)
			var right_side_coords: Vector4i = forward_coords + (right_direction * j)
			var side_color := (Game.TileIntents.LIGHT_RED if (j == side_amount or (i == 1 or i == 5)) else Game.TileIntents.RED) if getPhase() == 1 else Game.TileIntents.DARK_RED
			
			tile_intents.append(TileIntentDatastore.new(side_color,\
				OffsetDatastore.new(left_side_coords, true), coords))
				
			tile_intents.append(TileIntentDatastore.new(side_color,\
				OffsetDatastore.new(right_side_coords, true), coords))
		
		var forward_color := (Game.TileIntents.LIGHT_RED if (i == 5 or i == 1) else Game.TileIntents.RED) if getPhase() == 1 else Game.TileIntents.DARK_RED
		tile_intents.append(TileIntentDatastore.new(forward_color,\
			OffsetDatastore.new(forward_coords, true), coords))
	
	return BossTileIntents.new(tile_intents, tile_results)
	
func onGrandSlash(enemies: Array, tiles: Array, use_type: UseType) -> Array:
	var actions: Array = []
	if use_type == UseType.START:
		var slash_tile_rotation: int = boss_datastore.getConditionResult("GrandSlash").getTileRotation()
		actions.append(ChangeTileRotationAction.new(self, slash_tile_rotation))
		
		var animation_action := AnimationAction.new(self, "GrandSlash")
		animation_action.setActionDelay(GRAND_SLASH_ACTION_DELAY)
		actions.append(animation_action)
		
		var left_direction := Game.getCubeDirectionExtra((tile_rotation - 2) % 6)
		var right_direction := Game.getCubeDirectionExtra((tile_rotation + 2) % 6)
		var direction := Game.getCubeDirectionExtra(slash_tile_rotation)
		var enemy_tiles: Array = Game.getEnemyUnits(team).map(func(x: CardGD): return x.getTile())
		
		var lower_damage_tiles: Array = []
		var higher_damage_tiles: Array = []
		for i: int in range(1, 6):
			var forward_coords: Vector4i = coords + (direction * i)
			var side_amount: int = 2 if i == 1 else 3
			for j: int in range(1, side_amount + 1):
				var left_side_coords: Vector4i = forward_coords + (left_direction * j)
				var right_side_coords: Vector4i = forward_coords + (right_direction * j)
				
				for side_coords: Vector4i in [left_side_coords, right_side_coords]:
					var SideTile: TileGD = Game.getTile(side_coords)
					if SideTile == null: continue
					if SideTile in enemy_tiles: lower_damage_tiles.append(SideTile)
				
			var ForwardTile: TileGD = Game.getTile(forward_coords)
			if ForwardTile == null: continue
			if ForwardTile in enemy_tiles: higher_damage_tiles.append(ForwardTile)
		
		if getPhase() == 2:
			var enemy_damage_tiles: Array = lower_damage_tiles + higher_damage_tiles
			var enemy_cards: Array = enemy_damage_tiles.map(func(x: TileGD): return Game.getFieldCard(x))
			actions.append(DamageAction.new(self, enemy_cards, attack, Game.DamageTypes.OTHER))
		elif getPhase() == 1:
			var higher_enemy_cards: Array = higher_damage_tiles.map(func(x: TileGD): return Game.getFieldCard(x))
			actions.append(DamageAction.new(self, higher_enemy_cards, attack, Game.DamageTypes.OTHER))
			
			var lower_enemy_cards: Array = lower_damage_tiles.map(func(x: TileGD): return Game.getFieldCard(x))
			actions.append(DamageAction.new(self, lower_enemy_cards, attack - 1, Game.DamageTypes.OTHER))
	return actions
	
func onGrandSlashCondition() -> BossIntentConditionResultGrandSlash:
	var distance: int = 3
	var enemy_tiles: Array = Game.getEnemyUnits(team).map(func(x: CardGD): return x.getTile())
	
	var tile_rotation_to_enemy_amount: Dictionary[int, int] = {}
	for index: int in range(6):
		var direction := Game.getCubeDirectionExtra(index)
		var new_coords: Vector4i = coords + (direction * distance)
		var CheckTile: TileGD = Game.getTile(new_coords)
		if CheckTile == null: continue
		var tiles: Array = Game.getAdjacentTiles(CheckTile, 1) + [CheckTile]
		if tiles.is_empty(): continue
		var enemy_amount: int = tiles.filter(func(x: TileGD): return x in enemy_tiles).size()
		tile_rotation_to_enemy_amount[index] = enemy_amount
	
	var tile_rotations: Array = tile_rotation_to_enemy_amount.keys()
	if tile_rotations.is_empty(): return BossIntentConditionResultGrandSlash.new(false)
	tile_rotations.sort_custom(func(x: int, y: int):\
		return tile_rotation_to_enemy_amount[x] > tile_rotation_to_enemy_amount[y])
	
	var best_tile_rotation: int = tile_rotations[0]
	if tile_rotation_to_enemy_amount[best_tile_rotation] == 0:
		return BossIntentConditionResultGrandSlash.new(false)
	
	var boss_intent_condition_result := BossIntentConditionResultGrandSlash.new(true)
	boss_intent_condition_result.setTileRotation(best_tile_rotation)
	return boss_intent_condition_result
#endregion

#region JumpAttack
func onJumpAttackSetIntents() -> BossTileIntents:
	var tile_intents: Array[TileIntentDatastore] = []
	var tile_results: Dictionary[TileGD, String] = {}
	var condition: BossIntentConditionResultSilasJumpAttack = boss_datastore.getConditionResult("JumpAttack")
	var JumpToTile: TileGD = Game.getTile(condition.getJumpToCoords())
	var StartJumpTile: TileGD = Game.getTile(condition.getStartJumpCoords())
	if JumpToTile != null and StartJumpTile != null:
		var low_damage_tiles: Array = []
		var high_damage_tiles: Array = []
		var relative_tr: int = Game.getRelativeTileRotation(StartJumpTile, JumpToTile)
		var direction: Vector4i = Game.getCubeDirectionExtra(relative_tr)
		var left_direction: Vector4i = Game.getCubeDirectionExtra((relative_tr - 1) % 6)
		var right_direction: Vector4i = Game.getCubeDirectionExtra((relative_tr + 1) % 6)
		for i: int in range(1, 3):
			var forward_coords := direction * i
			var ForwardTile: TileGD = Game.getTile(forward_coords + StartJumpTile.getCoords())
			if ForwardTile != null:
				high_damage_tiles.append(ForwardTile)
			
			var left_mult_direction := StartJumpTile.getCoords() + (left_direction) + (direction * (i - 1))
			var LeftSideTile: TileGD = Game.getTile(left_mult_direction)
			if LeftSideTile != null:
				low_damage_tiles.append(LeftSideTile)
				
			var right_mult_direction := StartJumpTile.getCoords() + (right_direction) + (direction * (i - 1))
			var RightSideTile: TileGD = Game.getTile(right_mult_direction)
			if RightSideTile != null:
				low_damage_tiles.append(RightSideTile)
			
		high_damage_tiles += Game.getAdjacentTiles(JumpToTile)
		low_damage_tiles += Game.getAdjacentTiles(JumpToTile, 2)
		low_damage_tiles = low_damage_tiles.filter(func(x: TileGD): return x not in high_damage_tiles)
		
		if getPhase() == 2:
			high_damage_tiles += low_damage_tiles
			low_damage_tiles = []
			
		for LowDamageTile: TileGD in low_damage_tiles:
			tile_intents.append(TileIntentDatastore.new(Game.TileIntents.LIGHT_RED, null, LowDamageTile.getCoords()))
			tile_results[LowDamageTile] = "LowDamageTile"
			
		var tile_color := Game.TileIntents.RED if getPhase() == 1 else Game.TileIntents.DARK_RED
		for HighDamageTile: TileGD in high_damage_tiles:
			tile_intents.append(TileIntentDatastore.new(tile_color, null, HighDamageTile.getCoords()))
			tile_results[HighDamageTile] = "HighDamageTile"

		tile_intents.append(TileIntentDatastore.new(Game.TileIntents.BLACK, null, JumpToTile.getCoords()))
		tile_results[StartJumpTile] = "StartJumpTile"
		tile_results[JumpToTile] = "JumpToTile"
	return BossTileIntents.new(tile_intents, tile_results)
	
func onJumpAttack(enemies: Array, tiles: Array, use_type: UseType) -> Array:
	var actions: Array = []
	if use_type == UseType.START:
		var tile_results := boss_datastore.getTileResults()
		
		var StartJumpTile: TileGD
		for TileResultTile: TileGD in tile_results.keys():
			if TileResultTile == null: continue
			match tile_results[TileResultTile]:
				"StartJumpTile": StartJumpTile = TileResultTile
			
		if StartJumpTile in tiles:
			actions.append(MovementAction.new(self, StartJumpTile.getMovementPathTiles(), false))
					
	elif use_type == UseType.END:
		var tile_results := boss_datastore.getTileResults()
		var tile_results_tiles: Array = tile_results.values()
		
		var StartJumpTile: TileGD
		var JumpToTile: TileGD
		var low_damage_tiles: Array = []
		var high_damage_tiles: Array = []
		
		for TileResultTile: TileGD in tile_results.keys():
			if TileResultTile == null: continue
			match tile_results[TileResultTile]:
				"JumpToTile": JumpToTile = TileResultTile
				"StartJumpTile": StartJumpTile = TileResultTile
				"LowDamageTile": low_damage_tiles.append(TileResultTile)
				"HighDamageTile": high_damage_tiles.append(TileResultTile)
		
		if getTile() != StartJumpTile: return []
		actions.append(AnimationModifierAction.new(self, "Jump", ""))
		actions.append(MoveToTileAction.new(self, JumpToTile, true))
		
		var low_damage_enemies: Array = low_damage_tiles.map(func(x: TileGD): return Game.getEnemyFieldCard(x, team)).filter(func(x: CardGD): return x != null)
		var high_damage_enemies: Array = high_damage_tiles.map(func(x: TileGD): return Game.getEnemyFieldCard(x, team)).filter(func(x: CardGD): return x != null)
		
		actions.append(DamageAction.new(self, high_damage_enemies, attack, Game.DamageTypes.OTHER))
		actions.append(DamageAction.new(self, low_damage_enemies, attack - 1, Game.DamageTypes.OTHER))
	return actions
	
func onJumpAttackCondition() -> BossIntentConditionResult:
	var tiles: Array = getsetMovementRange(max_speed)
	tiles.append(getTile())
	tiles.shuffle()
	var enemy_tiles: Array = Game.getEnemyUnits(team).map(func(x: CardGD): return x.getTile())
	if !tiles.is_empty():
		for StartJumpTile: TileGD in tiles:
			for diag: Vector4i in Game.getCubeDirectionsExtra():
				diag *= JUMP_ATTACK_DISTANCE
				var jump_to_coords: Vector4i = diag + StartJumpTile.getCoords()
				var JumpToTile: TileGD = Game.getTile(jump_to_coords)
				if JumpToTile == null: continue
				if JumpToTile in enemy_tiles:
					var condition := BossIntentConditionResultSilasJumpAttack.new(true)
					condition.setStartJumpCoords(StartJumpTile.getCoords())
					condition.setJumpToCoords(jump_to_coords)
					return condition
	
	return BossIntentConditionResultSilasJumpAttack.new(false)
#endregion

#region LongSlash
func onLongSlashSetIntents() -> BossTileIntents:
	var tile_intents: Array[TileIntentDatastore] = []
	var new_coords: Array = []
	var direction: Vector4i = Game.getCubeDirectionExtra(0)
	var tile_color := Game.TileIntents.RED if getPhase() == 1 else Game.TileIntents.DARK_RED
	
	var max_range: int = LONG_SLASH_PHASE_ONE_RANGE if getPhase() == 1 else LONG_SLASH_PHASE_TWO_RANGE
	for i: int in range(1, max_range + 1):
		tile_intents.append(TileIntentDatastore.new(tile_color,\
			OffsetDatastore.new(direction * i, true, tile_rotation), coords))
			
	if isSpinningSword():
		for x: Vector4i in Game.getCubeDirectionsExtra():
			tile_intents.append(TileIntentDatastore.new(tile_color, OffsetDatastore.new(x, true), coords))
			
	return BossTileIntents.new(tile_intents, {})
	
func onLongSlash(enemies: Array, tiles: Array, use_type: UseType) -> Array:
	if use_type == UseType.START:
		active_speed = LONG_SLASH_SPEED_LIMIT
	
	tiles = getsetMovementRange(active_speed)
	if use_type == UseType.END: tiles.append(getTile())
	
	var DFL := DefaultFightLogic.new(self, tiles, enemies, [])
	var potential_killables: Array = enemies.filter(func(x: CardGD): return DFL.isAttackableKillable(x, self))
	var attackables: Dictionary[CardGD, TileGD] = getLongSlashAttackables(potential_killables, tiles)
	
	if attackables.values().all(func(x: TileGD): return x == null):
		var potential_attackables: Array = enemies.filter(func(x: CardGD): return x not in potential_killables)
		attackables = getLongSlashAttackables(potential_attackables, tiles)
	
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
	elif use_type == UseType.END:
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
		
		var max_range: int = LONG_SLASH_PHASE_ONE_RANGE if getPhase() == 1 else LONG_SLASH_PHASE_TWO_RANGE
		for i in range(1, max_range + 1):
			var multed_diagonal := diagonal * i
			var NewTile: TileGD = Game.getTile(multed_diagonal + coords)
			
			if NewTile != null:
				var index: int = all_enemy_tiles.find(NewTile)
				if index == -1: continue
				damagables.append(all_enemies[index])
		
		var animation_action := AnimationAction.new(self, "LongSlash")
		animation_action.setActionDelay(LONG_SLASH_ACTION_DELAY)
		actions.append(animation_action)
		
		if isSpinningSword():
			var adjacent_enemies: Array = Game.getEnemyUnits(team).filter(func(x: CardGD): return Game.isAdjacent(x.getTile(), getTile()))
			adjacent_enemies = adjacent_enemies.filter(func(x: CardGD): return x not in damagables)
			damagables += adjacent_enemies
		actions.append(DamageAction.new(self, damagables, attack, Game.DamageTypes.OTHER))
	return actions
	
func getLongSlashAttackables(enemies: Array, tiles: Array) -> Dictionary[CardGD, TileGD]:
	var attackables: Dictionary[CardGD, TileGD] = {}
	for EnemyCard: CardGD in enemies:
		attackables[EnemyCard] = isLongSlashEnemyAttackable(EnemyCard, tiles)
	return attackables
	
func isLongSlashEnemyAttackable(EnemyCard: CardGD, tiles: Array) -> TileGD:
	var cube_directions: Array = Game.getCubeDirectionsExtra()
	cube_directions.shuffle()
	var max_range: int = LONG_SLASH_PHASE_ONE_RANGE if getPhase() == 1 else LONG_SLASH_PHASE_TWO_RANGE
	for diagonal: Vector4i in cube_directions:
		for i in range(max_range, 0, -1):
			var multed_diagonal: Vector4i = diagonal * i
			var NewTile: TileGD = Game.getTile(EnemyCard.getCoords() + multed_diagonal)
			if NewTile != null and NewTile in tiles:
				return NewTile
	return null
#endregion

#region Passives
func onRampagePassive() -> void:
	var actions: Array = []
	for EnemyCard: CardGD in getVisibleFieldCardsEnemies():
		actions.append(StatAction.new(StatInfo.new(EnemyCard, Game.Stats.MAX_SPEED, -1, 1)))
	onPushAction(actions)
#endregion

#region Phase Change
func onChangeBossPhase() -> void:
	super()
	onDestroySpinningSwordVFX(true)
	onForceAction(FieldInfoVisibleAction.new(self, false))
	onForceAction(AnimationModifierAction.new(self, "Idle", "PhaseTwo"))
	onForceAction(AnimationAction.new(self, "PhaseChange"))
	onForceAction(ClearTileIntentsAction.new())
	
func onChangeBossPhasePostDelay() -> void:
	super()
	
	onIdle()
	var is_valid_boss_intent: bool = boss_intent.name in getBossIntentsFromInfo().map(func(x: BossIntent): return x.name)
	onForceAction(ChangeBossIntentAction.new(getBossIntentByName(boss_intent.name) if is_valid_boss_intent else getBossIntentsFromInfo().pick_random()))
	onForceAction(FieldInfoVisibleAction.new(self, true))
	
