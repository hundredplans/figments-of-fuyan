class_name AIManagerGD
extends Node

var SpectateCamera: SpectateCameraGD
var Vision: VisionGD
var LevelMap: LevelMapGD
var Tiles: TilesGD
var Units: UnitsGD
var Combat: CombatGD

var active_movement_order: Array = []
var invisible_movement_tracker: Array = []
const FIRST_MOVE_DELAY: float = 0.3

func onDeathFinished(Unit: UnitGD) -> void:
	active_movement_order.erase(Unit)

func onAIEndTurnPhaseStart() -> void:
	var AppliedBy := AppliedByGD.new("EndAIPhase")
	for Unit in Units.on_units(TeamRelationGD.new(1)):
		Unit.stats("active_speed", Unit.max_speed, AppliedBy, true)
		Units.setUnitStatus(Unit, "TurnUsed")

func onAIPhaseStart() -> void:
	var AppliedBy := AppliedByGD.new("StartAIPhase")
	for Unit in Units.on_units(TeamRelationGD.new(1)):
		Unit.stats("active_speed", Unit.max_speed, AppliedBy, true)
		Unit.attack_amount = 1
		Units.setUnitStatus(Unit, "TurnUnused")
	onBeginMoveAIUnits()
	
func onBeginMoveAIUnits() -> void:
	active_movement_order = onCreateMovementOrder()
	invisible_movement_tracker = []
	onMoveNextAIUnit()

func onCreateMovementOrder() -> Array:
	var units: Array = Units.on_units(TeamRelationGD.new(1))
	var movement_order: Array = []
	for Unit in units:
		var value: int = Unit.ai.aia if Unit.getVisibleEnemies().is_empty() else Unit.ai.aic
		movement_order.append({"Unit": Unit, "value": value})
	movement_order.sort_custom(func(x: Dictionary, y: Dictionary): return x.value > y.value)
	return movement_order.map(func(x: Dictionary): return x.Unit)

func onMoveNextAIUnit() -> void:
	LevelMap.setActionLock("UnitActionDisabled")
	if active_movement_order.size() > 0:
		var Unit: UnitGD = active_movement_order.pop_front()
		var wait: bool = onUseTargetAbilities(Unit)
		if !wait: onAfterTargetAbility(Unit)
	else:
		if invisible_movement_tracker.all(func(x: bool): return x):
			await get_tree().create_timer(Units.AFTER_MOVEMENT_DELAY).timeout
			
		LevelMap.setActionLock("UnitActionDisabled")
		LevelMap.on_change_game_phase("AIEndTurnPhase")

func onAfterTargetAbility(Unit: UnitGD) -> void:
	if !Unit.is_dead:
		Units.setUnitStatus(Unit, "TurnActive")
		onBeginUnitMovement(Unit)
	else: Units.onAIMoveFinisher(Unit)

func onBeginUnitMovement(Unit: UnitGD) -> void:
	var f: int = Time.get_ticks_msec()
	var movement_path: MovementPathGD
	var visible_enemies: Array = Unit.getVisibleEnemies()
	
	if visible_enemies.is_empty(): movement_path = await onNoneInVisionMovement(Unit)
	else: movement_path = await onEnemyInVisionMovement(Unit, visible_enemies)
	onMoveUnitAI(Unit, movement_path)

func onMoveUnitAI(Unit: UnitGD, movement_path: MovementPathGD) -> void:
	if movement_path != null:
		Tiles.on_remove_tile_material(Unit.Tile, "")
		invisible_movement_tracker.append(movement_path.isVisArrayInvis())
		var start_delay: bool = false
		for i in range(movement_path.fneighbours.size()):
			var fneighbour: FneighbourGD = movement_path.fneighbours[i]
			var vis_info: VisInfoGD = movement_path.vis_array[i] if movement_path.vis_array.size() > i else {}
			var Tile: TileGD = fneighbour.Tile
			if !start_delay and (vis_info.isNull() or vis_info.total_vision != VisInfoGD.INVISIBLE):
				Units.onPushArgDelay(Unit, FIRST_MOVE_DELAY, SpectateCamera.onSpectate.bind(Unit), onStartDelay.bind(Unit, Tile))
				start_delay = true
			
			if !(i == movement_path.fneighbours.size() - 1 and movement_path.is_attack): Units.onMoveToTileAI(Unit, fneighbour, movement_path)
			elif Unit.onCanAttack(): Units.onAttackEnemy(Unit, Tile)
	Units.onAIMoveFinisher(Unit, movement_path)

func onStartDelay(Unit: UnitGD, Tile: TileGD) -> void:
	Unit.Model._look_at(Tile)
	SpectateCamera.onSpectate(Unit)

func onEnemyInVisionMovement(Unit: UnitGD, visible_enemies: Array = Unit.getVisibleEnemies()) -> MovementPathGD:
	var movement_path: MovementPathGD = onRollEnemyInVisionMovement(Unit, visible_enemies)
	if movement_path != null:
		await onCalculateVisibilityPath(Unit, movement_path)
		return movement_path
	return null
	
func onRollEnemyInVisionMovement(Unit: UnitGD, visible_enemies: Array) -> MovementPathGD:
	var movement_paths: Array = onRemoveLethalMovementPaths(Unit, Tiles.onCreateMovementPaths(Unit))
	var visible_allies: Array = Unit.getVisibleAllies()
	if movement_paths.size() > 0:
		if Combat.onCanKillAtFullSpeed(Unit, movement_paths): return onKillMovement(Unit, movement_paths)
		movement_paths = onRemoveFallMovementPaths(movement_paths)
		if movement_paths.size() > 0:
			var is_teamwork: bool = false
			if visible_allies.size() > 0: is_teamwork = onTeamworkConfidenceRoll(Unit)
			
			if is_teamwork: return onTeamworkMovement(Unit, true, movement_paths)
			if onConfidenceRoll(Unit, visible_enemies.size()): return onRunAtEnemyMovement(Unit, movement_paths, visible_enemies)
			return onRunAwayMovement(Unit, movement_paths, visible_enemies)
	return null
	
func onConfidenceRoll(Unit: UnitGD, amount: int) -> bool:
	var confidence: float = Unit.ai.aic
	confidence = clamp(confidence + 1 - amount, 1, 7) # lose 1 confience per enemy unit in vision
	return randf() <= ((confidence * 8) + 1) / float(50)
	
func onTeamworkConfidenceRoll(Unit: UnitGD) -> bool:
	var cf: int = pow(Unit.ai.aic, 2) 
	var tw: int = pow(Unit.ai.ait, 2)
	var total: int = cf + tw
	return randf() < tw / total
	
func onRemoveLethalMovementPaths(Unit: UnitGD, movement_paths: Array) -> Array:
	return movement_paths.filter(isMovementPathNonLethal.bind(Unit))
	
func isMovementPathNonLethal(movement_path: MovementPathGD, Unit: UnitGD) -> bool:
	var total: int = 0
	for fall_damage in movement_path.fall_damages.values():
		fall_damage += total
	return total < Unit.health
	
func onRemoveFallMovementPaths(movement_paths: Array) -> Array:
	return movement_paths.filter(isMovementPathNonFallDamage)
	
func isMovementPathNonFallDamage(movement_path: MovementPathGD) -> bool:
	var fall_damages: Array = movement_path.fall_damages.values()
	return fall_damages.all(func(x: int): return x == 0)
	
func onCreateAverageDistanceToUnits(movement_paths: Array, units: Array) -> Array:
	var tile_distances: Array = []
	for movement_path in movement_paths:
		var distance: float = onFindAverageDistanceToUnits(movement_path.DestinationTile, units)
		tile_distances.append({"movement_path": movement_path, "distance": distance})
	return tile_distances
	
func onFindAverageDistanceToUnits(Tile: TileGD, units: Array) -> float:
	var distance: float = 0
	for Unit in units:
		distance += Tiles.tile_distance(Unit.Tile, Tile)
	distance /= float(units.size())
	return distance
	
func onAwarenessRoll(Unit: UnitGD) -> bool:
	return randf() < float(Unit.ai.aiw) / float(7)
	
func onAwarenessMovementPaths(Unit: UnitGD, movement_paths: Array, visible_enemies: Array) -> Array:
	var awareness_roll: bool = onAwarenessRoll(Unit)
	if awareness_roll:
		var new_paths: Array = movement_paths.filter(onAwarenessTileDistanceToEnemies.bind(visible_enemies))
		if new_paths.size() > 0: return new_paths
	return movement_paths
	
func onAwarenessTileDistanceToEnemies(movement_path: MovementPathGD, visible_enemies: Array) -> bool:
	for Unit in visible_enemies:
		if Unit.max_speed + 1 >= Tiles.tile_distance(Unit.Tile, movement_path.DestinationTile):
			return false
	return true
	
func onTeamworkMovement(Unit: UnitGD, enemy_movement: bool, movement_paths: Array = onRemoveFallMovementPaths(Tiles.onCreateMovementPaths(Unit))) -> MovementPathGD:
	if enemy_movement: movement_paths = onAwarenessMovementPaths(Unit, movement_paths, Unit.getVisibleEnemies())
	setMoveState(Unit, "TEAMWORK")
	var visible_allies: Array = Unit.getVisibleAllies()
	var random_ally: UnitGD = visible_allies[randi() % visible_allies.size()]
	
	var paths_with_distance: Dictionary = onLevelMovementPaths(random_ally, movement_paths)
	var distance: int = onFindTeamworkDistance(Unit)
	for i in range(7):
		if distance == i:
			if paths_with_distance[i].is_empty():
				distance += 1
				if distance == 6: return null
			else:
				break
	return paths_with_distance[distance][randi() % paths_with_distance[distance].size()]
	
	
const EXPLORE_MOVEMENT_RANGE: int = 5
func onExploreMovement(Unit: UnitGD) -> MovementPathGD:
	setMoveState(Unit, "EXPLORE")
	var enemy_vision: Array = Vision.getTeamVision(TeamRelationGD.new(1))
	var ExploreTile: TileGD = Unit.ai_info.ExploreTile
	if ExploreTile == null or ExploreTile in enemy_vision:
		ExploreTile = onPickRandomExploreTile(enemy_vision)
		if ExploreTile == null: return onRandomMovement(Unit)
		
	var movement_paths: Array = onRemoveFallMovementPaths(Tiles.onCreateMovementPaths(Unit, EXPLORE_MOVEMENT_RANGE))
	var tile_distances: Array = []
	for movement_path in movement_paths:
		var distance: float = Tiles.tile_distance(movement_path.DestinationTile, ExploreTile)
		tile_distances.append({"movement_path": movement_path, "distance": distance})
		
	tile_distances.sort_custom(func(x: Dictionary, y: Dictionary): return x.distance < y.distance)
	if tile_distances.size() > 0: return tile_distances[0].movement_path
	return null
	
	
func onRandomMovement(Unit: UnitGD) -> MovementPathGD:
	setMoveState(Unit, "RANDOM")
	var speed: int = getRandomMovementSpeed(Unit)
	var movement_paths: Array = onRemoveInvalidDistanceRandomMovementPaths(Unit, speed)
	if movement_paths.size() > 0:
		return movement_paths[randi() % movement_paths.size()]
	return null


func onKillMovement(Unit: UnitGD, movement_paths: Array) -> MovementPathGD:
	setMoveState(Unit, "KILL")
	var attack_paths: Array = Tiles.onKillMovementPaths(Unit, movement_paths)
	return attack_paths[randi() % attack_paths.size()]
	
	
func onRunAtEnemyMovement(Unit: UnitGD, movement_paths: Array, visible_enemies: Array) -> MovementPathGD:
	movement_paths = onAwarenessMovementPaths(Unit, movement_paths, visible_enemies)
	setMoveState(Unit, "RUN AT")
	var woundable_enemy_paths: Array = []
	for _Unit in visible_enemies:
		var movement_path := MovementPathGD.onFindTile(_Unit.Tile, movement_paths)
		if movement_path != null: woundable_enemy_paths.append(movement_path)
		
	if woundable_enemy_paths.size() > 0:
		return woundable_enemy_paths[randi() % woundable_enemy_paths.size()]
		
	var tile_distances: Array = onCreateAverageDistanceToUnits(movement_paths, visible_enemies)
	tile_distances.sort_custom(func(x: Dictionary, y: Dictionary): return x.distance < y.distance)
	return tile_distances[0].movement_path
	
	
func onRunAwayMovement(Unit: UnitGD, movement_paths: Array, visible_enemies: Array) -> MovementPathGD:
	movement_paths = onAwarenessMovementPaths(Unit, movement_paths, visible_enemies)
	setMoveState(Unit, "RUN AWAY")
	var tile_distances: Array = onCreateAverageDistanceToUnits(movement_paths, visible_enemies)
	tile_distances.sort_custom(func(x: Dictionary, y: Dictionary): return x.distance > y.distance)
	
	if tile_distances[0].distance <= onFindAverageDistanceToUnits(Unit.Tile, visible_enemies):
		return null
	return tile_distances[0].movement_path
	
	
func setMoveState(Unit: UnitGD, type: String) -> void:
	Unit.ai_info.setMoveState(type)
	
func onPickRandomExploreTile(enemy_vision: Array) -> TileGD:
	var tiles: Array = Tiles.get_children()
	var ally_vision: Array = Vision.getTeamVision(TeamRelationGD.new())
	var outlier_tiles: Array = tiles.filter(func(x: TileGD): return x in ally_vision and x not in enemy_vision)
	if outlier_tiles.size() > 0: return outlier_tiles[randi() % outlier_tiles.size()]
	return null
	
func onFindTeamworkDistance(Unit: UnitGD) -> int:
	var roll_for_one: bool = randf() < pow(Unit.ai.ait, 2) / float(50)
	if !roll_for_one:
		var roll_for_two: bool = randf() < pow(Unit.ai.ait, 2) / float(50)
		if roll_for_two: return 2
		return 3
	return 1
	
func onLevelMovementPaths(_Unit: UnitGD, movement_paths: Array) -> Dictionary:
	var paths_with_distance: Dictionary = {1: [], 2: [], 3: [], 4: [], 5: [], 6: [], 7: [], 8: [], 9: []}
	for movement_path in movement_paths:
		paths_with_distance[Tiles.tile_distance(movement_path.DestinationTile, _Unit.Tile)].append(movement_path)
	return paths_with_distance
	
func onRollNoneInVisionMovement(Unit: UnitGD) -> MovementPathGD:
	var visible_allies: Array = Unit.getVisibleAllies()
	var is_teamwork: bool = false
	if visible_allies.size() > 0: is_teamwork = onTeamworkConfidenceRoll(Unit)

	if is_teamwork: return onTeamworkMovement(Unit, false)
	if onAdventureRoll(Unit): return onExploreMovement(Unit)
	return onRandomMovement(Unit)

func onAdventureRoll(Unit: UnitGD) -> bool:
	return randf() <= (Unit.ai.aia / float(7))
	
func onNoneInVisionMovement(Unit: UnitGD) -> MovementPathGD:
	var movement_path: MovementPathGD = onRollNoneInVisionMovement(Unit)
	if movement_path != null:
		var visions: Array = []
		await onCalculateVisibilityPath(Unit, movement_path, visions)
		var change_index: int = onMovementPathEnterVision(movement_path)
		if change_index == -1: return movement_path
		var index: int = MovementPathGD.onFindEnterVisionIndex(movement_path)
		if index != -1 and index != movement_path.fneighbours.size() - 1:
			movement_path.vis_array.resize(index + 1)
			movement_path.fneighbours.resize(index + 1)
			movement_path.DestinationTile = movement_path.fneighbours[movement_path.fneighbours.size() - 1].Tile
			
			var Tile: TileGD = Unit.Tile
			var speed: int = Unit.speed
			Unit.onChangeTile(movement_path.DestinationTile)
			Unit.speed = Unit.speed - (index + 1)
			
			for vis_info in movement_path.vis_array:
				if !vis_info.isNull():
					Unit.visible_tiles = vis_info.tiles
					Vision.onProcessUnitVision(Unit, vis_info.unit_vision, [], false)
			
			var enemy_movement_path: MovementPathGD = await onEnemyInVisionMovement(Unit)
			if enemy_movement_path != null:
				movement_path.DestinationTile = enemy_movement_path.DestinationTile
				var size: int = enemy_movement_path.fneighbours.size()
				for i in range(size):
					movement_path.fneighbours.append(enemy_movement_path.fneighbours[i])
					movement_path.vis_array.append(enemy_movement_path.vis_array[i])
					
				for _Tile in enemy_movement_path.fall_damages:
					movement_path.fall_damages[_Tile] = enemy_movement_path.fall_damages[_Tile]
			
			for info in visions: info[0].visible_tiles = info[1]
			Unit.onChangeTile(Tile)
			Unit.speed = speed
	return movement_path

func onMovementPathEnterVision(movement_path: MovementPathGD) -> int:
	for i in range(movement_path.vis_array.size()):
		if !movement_path.vis_array[i].isNull() and movement_path.vis_array[i].total_vision == VisInfoGD.ENTER:
			return i
	return -1

func onCalculateVisibilityPath(Unit: UnitGD, movement_path: MovementPathGD, visions: Array = []) -> void:
	var default_rot: int = Unit.Model.rot
	var default_tile: TileGD = Unit.Tile
	var default_body_pos: Vector3 = Unit.Model.static_body.position
	var default_ray_pos: Vector3 = Unit.VisionRaycast.position
	
	await onChosenPathVisPath(Unit, movement_path, default_body_pos, default_ray_pos, visions)
	onCreateVisPath(movement_path.vis_array)
	Unit.onResetUnit(default_body_pos, default_ray_pos, default_rot, default_tile)

func onCreateVisPath(vis_array: Array) -> void:
	for vis_info in vis_array.filter(func(x: VisInfoGD): return !x.isNull()):
		var ally_intents: Array = vis_info.unit_vision.keys().filter(func(x: UnitGD): return x.team == 0).map(func(x: UnitGD): return vis_info.unit_vision[x])
		var path: int = VisInfoGD.INVISIBLE
		if ally_intents.any(func(x: int): return x == VisInfoGD.REGULAR): path = VisInfoGD.REGULAR
		else:
			var any_enter: bool = ally_intents.any(func(x: int): return x == VisInfoGD.ENTER)
			var any_exit: bool = ally_intents.any(func(x: int): return x == VisInfoGD.EXIT)
			if any_exit and any_enter: path = VisInfoGD.REGULAR
			elif any_exit: path = VisInfoGD.EXIT
			elif any_enter: path = VisInfoGD.ENTER
		
		vis_info.total_vision = path

func onChosenPathVisPath(Unit: UnitGD, movement_path: MovementPathGD, default_body_pos: Vector3, default_ray_pos: Vector3, visions: Array) -> void:
	visions = Units.all_units().map(func(x: UnitGD): return [x, x.visible_tiles.duplicate()])
	for i in range(movement_path.fneighbours.size()):
		if !(i == movement_path.fneighbours.size() - 1 and movement_path.is_attack):
			var fneighbour: FneighbourGD = movement_path.fneighbours[i]
			var Tile: TileGD = fneighbour.Tile
			onChosenPathSetupUnit(Unit, Tile, Tiles.getUnitPositionOnTile(Tile), default_body_pos, default_ray_pos)
			await get_tree().process_frame
			var vis_info: VisInfoGD = Unit.onCalculateVisionInfo()
			Unit.visible_tiles = vis_info.tiles
			Vision.onProcessUnitVision(Unit, vis_info.unit_vision, [], false)
			movement_path.vis_array.append(vis_info)
		else: movement_path.vis_array.append(VisInfoGD.new())

	for info in visions: info[0].visible_tiles = info[1]
		
func onChosenPathSetupUnit(Unit: UnitGD, Tile: TileGD, global: Vector3, default_body_pos: Vector3, default_ray_pos: Vector3) -> void:
	Unit.Model.static_body.global_position = global + default_body_pos
	Unit.VisionRaycast.global_position = global + default_ray_pos
	Unit.Model._look_at_body(Tile)
	Unit.onChangeTile(Tile)
	
func onRemoveInvalidDistanceRandomMovementPaths(Unit: UnitGD, speed: int) -> Array:
	var _movement_paths: Array = onRemoveFallMovementPaths(Tiles.onCreateMovementPaths(Unit, speed))
	var movement_paths: Array = []
	while(true):
		movement_paths = _movement_paths.filter(func(x: MovementPathGD):\
		return Tiles.tile_distance(x.DestinationTile, Unit.Tile) == speed)
		
		if _movement_paths.is_empty():
			speed -= 1
			if speed != 0: continue
		return movement_paths
	return []
func getRandomMovementSpeed(Unit: UnitGD) -> int:
	var lose_movement: int = 0
	for i in range(max(Unit.speed - 1, 0)):
		if randf() > 0.9: lose_movement += 1
	return Unit.speed - lose_movement

func onUseTargetAbilities(Unit: UnitGD) -> bool:
	var wait: bool = false
	for ability in Unit.abilities:
		if ability is TargetAbilityGD:
			ability.onTargetAbilityCondition()
			ability.can_affect = !(ability.tiles["affect"].is_empty())
			if Combat.isAbilityEnabled(Unit, ability):
				var Tile: TileGD = ability.onTargetAbilityConditionAI()
				if Tile != null:
					if !wait and Unit.Tile in Vision.getTeamVision(): SpectateCamera.onSpectate(Unit)
					Combat.onTargetAbility(Unit, ability, Tile)
					if !wait: Units.onAppendArgQueue(onAfterTargetAbility.bind(Unit))
					wait = true
	return wait
	
func getDangerList(Unit: UnitGD, units: Array = []) -> Array:
	var danger_list: Array = [] # Array of DangerInfoGD's
	var int_to_middle: int = 16 - (Unit.ai.aii * 2)
	var int_either_side: int = 10 - (Unit.ai.aii)
	#print(Unit.ai.aii)
	for _Unit in units:
		var danger_value: int = _Unit.ai_info.danger
		var top_cap: int = 50 if danger_value < 50 else danger_value
		var regular_to_middle: int = floor(abs(danger_value - 25) / float(5))
		
		var lower_bound: int = danger_value - int_either_side
		var upper_bound: int = danger_value + int_either_side
		
		if danger_value > 25:
			upper_bound = max(upper_bound - (regular_to_middle + int_to_middle), 25)
		else:
			lower_bound = min(lower_bound + regular_to_middle + int_to_middle, 25)
		
		lower_bound = clamp(lower_bound, 1, top_cap)
		upper_bound = clamp(upper_bound, 1, top_cap)
		var new_danger_value: int = randi_range(lower_bound, upper_bound)
		#print(danger_value)
		#print(lower_bound)
		#print(upper_bound)
		#print(new_danger_value)
		danger_list.append(DangerInfoGD.new(_Unit, new_danger_value))
	#print()
	return danger_list
	
func getAllyList() -> Array:
	return []
