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

func onAIPhaseStart() -> void:
	var AppliedBy := AppliedByGD.new("StartAIPhase")
	for Unit in Units.on_units(TeamRelationGD.new(1)):
		Unit.stats("active_speed", Unit.max_speed, AppliedBy, true)
		Unit.attack_amount = 1
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
		Units.setUnitStatus(Unit, UnitGD.TURN_ACTIVE)
		onBeginUnitMovement(Unit)
	else: Units.onAIMoveFinisher(Unit)

func onBeginUnitMovement(Unit: UnitGD) -> void:
	var movement_path: MovementPathGD
	var visible_enemies: Array = Unit.getVisibleEnemies()
	
	if visible_enemies.is_empty(): movement_path = await onNoneInVisionMovement(Unit)
	else: movement_path = await onEnemyInVisionMovement(Unit, visible_enemies)
	onMoveUnitAI(Unit, movement_path)

func onMoveUnitAI(Unit: UnitGD, movement_path: MovementPathGD) -> void:
	if movement_path != null:
		Units.setUnitStatus(Unit, UnitGD.TURN_ACTIVE)
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
	if movement_paths.size() > 0:
		if Combat.onCanKillAtFullSpeed(Unit, movement_paths): return onKillMovement(Unit, movement_paths)
		movement_paths = onRemoveFallMovementPaths(movement_paths)
		if movement_paths.size() > 0:
			if onConfidenceRoll(Unit, visible_enemies.size()): return onRunAtEnemyMovement(Unit, movement_paths, visible_enemies)
			return onRunAwayMovement(Unit, movement_paths, visible_enemies)
	return null
	
func onConfidenceRoll(Unit: UnitGD, amount: int) -> bool:
	var can_be_killed: int = -1 if Combat.onCanBeKilledAtFullSpeed(Unit) else 1
	var plus_amount: int = Unit.getVisibleAllies().size()
	var confidence: float = Unit.ai.aic
	confidence = clamp(confidence + 1 - amount + plus_amount + can_be_killed, 1, 7)
	return randf() <= ((confidence * 8) + 1) / float(50)
	
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
	if awareness_roll: return onCreateAwarenessPaths(movement_paths, visible_enemies)
	return movement_paths
	
func onCreateAwarenessPaths(movement_paths: Array, visible_enemies: Array) -> Array:
	var new_paths: Array = movement_paths.filter(onAwarenessTileDistanceToEnemies.bind(visible_enemies))
	if new_paths.size() > 0: return new_paths
	return movement_paths
	
func onAwarenessTileDistanceToEnemies(movement_path: MovementPathGD, visible_enemies: Array) -> bool:
	for Unit in visible_enemies:
		if Unit.max_speed + 1 >= Tiles.tile_distance(Unit.Tile, movement_path.DestinationTile):
			return false
	return true
	
func onTeamworkMovement(Unit: UnitGD, movement_paths: Array = onRemoveFallMovementPaths(Tiles.onCreateMovementPaths(Unit))) -> MovementPathGD:
	setMoveState(Unit, "TEAMWORK")
	var visible_allies: Array = Unit.getVisibleAllies()
	
	var attack_paths: Array = MovementPathGD.onFindAttackPath(movement_paths)
	attack_paths = attack_paths.filter(onRemoveInvalidAttackPath.bind(visible_allies))
	if attack_paths.size() > 0: return onIntelligenceAttackPath(Unit, attack_paths)
	
	var paths_with_distance: Dictionary = onLevelMovementPaths(visible_allies, movement_paths)
	var distance: int = onFindTeamworkDistance(Unit)
	for i in range(7):
		if distance == i:
			if paths_with_distance[i].is_empty():
				distance += 1
				if distance == 6: return null
				continue
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
	return onIntelligenceAttackPath(Unit, attack_paths)
	
enum {
	OFFENSE,
	CAUTIOUS,
	CHARGE
}

func onRunAtRoll(Unit: UnitGD) -> int:
	var roll: float = randf()
	var cautious: int = int(pow(Unit.ai.aiw, 2))
	var charge: int = int(pow(Unit.ai.aic, 2))
	var total: int = cautious + charge
	if Unit.getVisibleAllies().size() > 0:
		# trifecta between offense (teamwork), cautious (awareness) and charge (confidence)
		var offense: int = int(pow(Unit.ai.ait, 2))
		total += offense
		var segment: float = 1.0 / total
	
		if roll < segment * cautious: return CAUTIOUS
		elif roll < (segment * charge) + (segment * cautious): return CHARGE
		return OFFENSE
	return CAUTIOUS if (roll < float(cautious) / total) else CHARGE
	
func onRunAtEnemyMovement(Unit: UnitGD, movement_paths: Array, visible_enemies: Array) -> MovementPathGD:
	var run_at_roll: int = onRunAtRoll(Unit)
	match run_at_roll:
		OFFENSE: return onOffenseEnemyMovement(Unit, movement_paths, visible_enemies)
		CAUTIOUS: return onCautiousEnemyMovement(Unit, movement_paths, visible_enemies)
		_: return onChargeEnemyMovement(Unit, movement_paths, visible_enemies)
	
func onRemoveInvalidAttackPath(movement_path: MovementPathGD, visible_allies: Array) -> bool:
	if visible_allies.size() > 0:
		visible_allies = visible_allies.map(func(x: UnitGD): return {"distance": Tiles.tile_distance(x.Tile, movement_path.DestinationTile), "Unit": x})
		visible_allies.sort_custom(func(x: Dictionary, y: Dictionary): return x.distance < y.distance)
		var closest_ally_info: Dictionary = visible_allies[0]
		return closest_ally_info.distance <= closest_ally_info.Unit.max_speed
	return false
	
func onIntelligenceAttackPath(Unit: UnitGD, attack_paths: Array) -> MovementPathGD:
	var danger_list: Array = getDangerList(Unit, MovementPathGD.onFindEnemyInAttackPaths(attack_paths))
	return MovementPathGD.onFindTile(danger_list[0].Unit.Tile, attack_paths)
	
func onOffenseEnemyMovement(Unit: UnitGD, movement_paths: Array, visible_enemies: Array) -> MovementPathGD:
	setMoveState(Unit, "OFFENSE")
	var visible_allies: Array = Unit.getVisibleAllies()
	
	var attack_paths: Array = MovementPathGD.onFindAttackPath(movement_paths)
	attack_paths = attack_paths.filter(onRemoveInvalidAttackPath.bind(visible_allies))
	if attack_paths.size() > 0: return onIntelligenceAttackPath(Unit, attack_paths)
	
	var enemy_distances: Array = onCreateAverageDistanceToUnits(movement_paths, visible_enemies)
	enemy_distances.sort_custom(func(x: Dictionary, y: Dictionary): return x.distance < y.distance)
	
	var ally_distances: Array = onCreateAverageDistanceToUnits(movement_paths, visible_allies)
	ally_distances.sort_custom(func(x: Dictionary, y: Dictionary): return x.distance < y.distance)
	
	var total_distances: Array = []
	for info in ally_distances:
		for _info in enemy_distances:
			if _info.movement_path == info.movement_path:
				total_distances.append({"movement_path": info.movement_path, "distance": info.distance + _info.distance})
				break
				
	total_distances.sort_custom(func(x: Dictionary, y: Dictionary): return x.distance < y.distance)
	return total_distances[0].movement_path
	
func onChargeEnemyMovement(Unit: UnitGD, movement_paths: Array, visible_enemies: Array) -> MovementPathGD:
	setMoveState(Unit, "CHARGE")
	var woundable_enemy_paths: Array = []
	for _Unit in visible_enemies:
		var movement_path := MovementPathGD.onFindTile(_Unit.Tile, movement_paths)
		if movement_path != null: woundable_enemy_paths.append(movement_path)
		
	if woundable_enemy_paths.size() > 0:
		return onIntelligenceAttackPath(Unit, woundable_enemy_paths)
		
	var tile_distances: Array = onCreateAverageDistanceToUnits(movement_paths, visible_enemies)
	tile_distances.sort_custom(func(x: Dictionary, y: Dictionary): return x.distance < y.distance)
	return tile_distances[0].movement_path
	
func onCautiousEnemyMovement(Unit: UnitGD, movement_paths: Array, visible_enemies: Array) -> MovementPathGD:
	setMoveState(Unit, "CAUTIOUS")
	movement_paths = onCreateAwarenessPaths(movement_paths, visible_enemies)
	
	var tile_distances: Array = onCreateAverageDistanceToUnits(movement_paths, visible_enemies)
	tile_distances.sort_custom(func(x: Dictionary, y: Dictionary): return x.distance < y.distance)
	return tile_distances[0].movement_path
	
func onRunAwayMovement(Unit: UnitGD, movement_paths: Array, visible_enemies: Array) -> MovementPathGD:
	if Unit.getVisibleAllies().size() == 0 or onDistanceMovementRoll(Unit): return onDistanceMovement(Unit, movement_paths, visible_enemies)
	return onTeamworkMovement(Unit, movement_paths)
	
func onDistanceMovementRoll(Unit: UnitGD) -> bool:
	return randf() > int(pow(Unit.ai.ait, 2)) / float(50)
	
func onDistanceMovement(Unit: UnitGD, movement_paths: Array, visible_enemies: Array) -> MovementPathGD:
	setMoveState(Unit, "DISTANCE")
	var tile_distances: Array = onCreateAverageDistanceToUnits(movement_paths, visible_enemies)
	tile_distances.sort_custom(func(x: Dictionary, y: Dictionary): return x.distance > y.distance)
	
	for _Unit in visible_enemies:
		if Tiles.tile_distance(_Unit.Tile, tile_distances[0].movement_path.DestinationTile) <= _Unit.max_speed + 1:
			return onChargeEnemyMovement(Unit, movement_paths, visible_enemies)
	
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
	
func onLevelMovementPaths(visible_allies: Array, movement_paths: Array) -> Dictionary:
	var paths_with_distance: Dictionary = {1: [], 2: [], 3: [], 4: [], 5: []}
	if visible_allies.size() > 0:
		for movement_path in movement_paths:
			var total_distance: int = 0
			for Unit in visible_allies: total_distance += Tiles.tile_distance(movement_path.DestinationTile, Unit.Tile)
			total_distance /= visible_allies.size()
			if total_distance < 6: paths_with_distance[total_distance].append(movement_path)
	return paths_with_distance
	
func onRollNoneInVisionMovement(Unit: UnitGD) -> MovementPathGD:
	var visible_allies: Array = Unit.getVisibleAllies()
	var is_teamwork: bool = false
	if visible_allies.size() > 0: is_teamwork = onTeamworkAwarenessRoll(Unit)

	if is_teamwork: return onTeamworkMovement(Unit)
	if onAdventureRoll(Unit): return onExploreMovement(Unit)
	return onRandomMovement(Unit)

func onTeamworkAwarenessRoll(Unit: UnitGD) -> bool:
	var aw: int = int(pow(Unit.ai.aiw, 2))
	var tw: int = int(pow(Unit.ai.ait, 2))
	var total: int = aw + tw
	return randf() < aw / float(total)

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
	var int_away_middle: int = 16 - (Unit.ai.aii * 2)
	var int_either_side: int = 10 - (Unit.ai.aii)
	var reg_away_mult: int = 3 if Unit.ai.aii <= 3 else (2 if Unit.ai.aii <= 5 else 1)
	for _Unit in units:
		var danger_value: int = _Unit.ai_info.danger + onDangerListNewStats(_Unit)
		var top_cap: int = 50 if danger_value < 50 else danger_value
		var regular_away_middle: int = floor(abs(danger_value - 25) / float(5)) * reg_away_mult
		
		var lower_bound: int = danger_value - int_either_side
		var upper_bound: int = danger_value + int_either_side
		
		if danger_value - 25 < 25 - danger_value: upper_bound += regular_away_middle + int_away_middle
		else: lower_bound -= regular_away_middle + int_away_middle
		
		lower_bound = clamp(lower_bound, 1, top_cap)
		upper_bound = clamp(upper_bound, 1, top_cap)
		var new_danger_value: int = randi_range(lower_bound, upper_bound)
		danger_list.append(DangerInfoGD.new(_Unit, new_danger_value))
	danger_list.sort_custom(func(x: DangerInfoGD, y: DangerInfoGD): return x.danger > y.danger)
	return danger_list
	
func getSafetyList(Unit: UnitGD, units: Array) -> Array:
	var safety_list: Array = []
	var tw_away_middle: int = 16 - (Unit.ai.ait * 2)
	var tw_either_side: int = 8 - Unit.ai.ait
	for _Unit in units:
		var safety_value: int = _Unit.ai_info.safety + onSafetyListNewStats(_Unit)
		var top_cap: int = 50 if safety_value < 50 else safety_value
		var regular_away_middle: int = floor(abs(safety_value - 25) / float(5))
		
		var lower_bound: int = safety_value - tw_either_side
		var upper_bound: int = safety_value + tw_either_side
		
		if safety_value - 25 < 25 - safety_value: upper_bound += regular_away_middle + tw_away_middle
		else: lower_bound -= regular_away_middle + tw_away_middle
		
		lower_bound = clamp(lower_bound, 1, top_cap)
		upper_bound = clamp(upper_bound, 1, top_cap)
		var new_safety_value: int = randi_range(lower_bound, upper_bound)
		safety_list.append(SafetyInfoGD.new(_Unit, new_safety_value))
	safety_list.sort_custom(func(x: SafetyInfoGD, y: SafetyInfoGD): return x.safety > y.safety)
	return safety_list
	
func onSafetyListNewStats(Unit: UnitGD) -> int:
	var total: int = 0
	total += (Unit.attack - Unit.base_card.attack) * 2
	total += (Unit.max_health - Unit.base_card.health) * 2
	total += (Unit.max_heath - Unit.health) * 2
	total += (Unit.max_speed - Unit.speed) * 4
	return total

func onDangerListNewStats(Unit: UnitGD) -> int: # speed = 8, att = 2 per
	var total: int = 0
	total += (Unit.max_speed - Unit.base_card.speed) * 8
	total += (Unit.attack - Unit.base_card.attack) * 2
	return total
