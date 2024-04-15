class_name AIManagerGD
extends Node

var Vision: VisionGD
var LevelMap: LevelMapGD
var Tiles: TilesGD
var Units: UnitsGD
var movement_order: Array = []
var active_movement_order: Array

func onDeathFinished(Unit: UnitGD) -> void:
	movement_order.erase(Unit)
	active_movement_order.erase(Unit)

func onAIEndTurnPhaseStart() -> void:
	for Unit in Units.on_units(1):
		Unit.stats("speed", 0, "EndAIPhase", true)

func onAIPhaseStart() -> void:
	for Unit in Units.on_units(1):
		Unit.stats("speed", Unit.max_speed, "StartAIPhase", true)
		Unit.attack_amount = 1
		
	onBeginMoveAIUnits()
	
func onBeginMoveAIUnits() -> void:
	invisible_movement_tracker = []
	active_movement_order = movement_order.duplicate()
	onMoveNextAIUnit()

func onMoveNextAIUnit() -> void:
	if active_movement_order.size() > 0:
		var Unit: UnitGD = active_movement_order.pop_front()
		Tiles.onCreateMovementPaths(Unit)
		var old_paths: Dictionary = Tiles.movement_paths.duplicate()
		var visible_enemies: Array = Unit.getVisibleEnemies()
		
		if visible_enemies.is_empty(): onChooseRandomMovementPath(Unit)
		else: onChaseEnemy(Unit, visible_enemies, old_paths)
	else:
		if invisible_movement_tracker.all(func(x: bool): return x):
			await get_tree().create_timer(Units.AFTER_MOVEMENT_DELAY).timeout
			
		LevelMap.setActionLock("UnitActionDisabled")
		LevelMap.on_change_game_phase("AIEndTurnPhase")

var invisible_movement_tracker: Array = []
func onChaseEnemy(Unit: UnitGD, visible_enemies: Array, old_paths: Dictionary) -> void:
	for EnemyUnit in visible_enemies:
		if EnemyUnit.Tile in Tiles.movement_paths.keys(): # Directly chase onto tile
			onChosenPathSelected(Unit, Tiles.movement_paths[EnemyUnit.Tile])
			return
		else:
			Tiles.onCreateMovementPaths(Unit, "AllyVision")
			if EnemyUnit.Tile in Tiles.movement_paths.keys():
				onChosenPathSelected(Unit, Tiles.movement_paths[EnemyUnit.Tile])
				return
				
	Tiles.movement_paths = old_paths
	onChooseRandomMovementPath(Unit)

func onChooseRandomMovementPath(Unit: UnitGD) -> void:
	var movement_paths: Array = []
	for key in Tiles.movement_paths:
		if typeof(key) != TYPE_STRING and Tiles.movement_paths[key].size == Unit.speed:
			movement_paths.append(Tiles.movement_paths[key])
	
	if movement_paths.size() > 0:
		onChosenPathSelected(Unit, movement_paths[randi() % movement_paths.size()])
	else: onMoveNextAIUnit()
	
func onChosenPathSelected(Unit: UnitGD, chosen_path: Dictionary) -> void:
	if chosen_path.size > 0:
		Tiles.on_remove_tile_material(Unit.Tile, "" if chosen_path.size == 1 and chosen_path.types[0].x == 1 else "IgnoreGreyscale")
	
	var visibility_path: Array = onCalculateVisibilityPath(Unit, chosen_path)
	invisible_movement_tracker.append(\
	visibility_path.any(func(x: Array): return x[1] == "Invisible") and visibility_path.all(func(x: Array): return x[1] == "Invisible"))
	
	for i in range(chosen_path.size):
		if chosen_path.types[i].x != 1: Units.onMoveToTileAI(Unit, chosen_path.tiles[i], chosen_path.types[i], visibility_path)
		else: Units.attack_enemy_or_target(Unit, chosen_path.tiles[i])

func onCalculateVisibilityPath(Unit: UnitGD, chosen_path: Dictionary) -> Array:
	var visibility_path: Array = [[Unit.Tile, Vision.is_unit_in_vision(Unit)]]
	var default_position: Vector3 = Unit.global_position
	var default_rot: int = Unit.Model.rot
	var default_tile: TileGD = Unit.Tile
	
	for i in range(chosen_path.size):
		if chosen_path.types[i].x != 1:
			var Tile: TileGD = chosen_path.tiles[i]
			Unit.global_position = Tiles.getUnitPositionOnTile(Tile)
			Unit.Tile = Tile
			Unit.Model.onLookAtRelative(Tile, Unit.Tile)
			visibility_path.append(onRayEnemyUnits(Unit))
	
	var movement_type_path: Array = []
	for i in range(visibility_path.size() - 1):
		movement_type_path.append([visibility_path[i + 1][0], onCalculateMovementType(visibility_path[i + 1][1], visibility_path[i][1])])
	
	onResetUnit(Unit, default_position, default_rot, default_tile)
	return movement_type_path
	
func onCalculateMovementType(destination_in_vision: bool, origin_in_vision: bool) -> String:
	if destination_in_vision:
		if origin_in_vision: return "Regular"
		return "IntoVision"
	elif origin_in_vision: return "OutOfVision"
	return "Invisible"

func onRayEnemyUnits(Unit: UnitGD) -> Array:
	for _Unit in Units.on_units(0):
		if Tiles.tile_distance(_Unit.Tile, Unit.Tile) <= 5 and _Unit.onRayEnemyUnit(Unit):
			return [Unit.Tile, true]
	return [Unit.Tile, false]

func onResetUnit(Unit: UnitGD, default_position: Vector3, default_rot: int, default_tile: TileGD) -> void:
	Unit.global_position = default_position
	Unit.Model.rot = default_rot
	Unit.Tile = default_tile
	Unit.Model.on_set_rotation()

func onUnitAwakened(Unit: UnitGD) -> void:
	if Unit.team == 1:
		onSortMovementOrder(Unit)

func onSortMovementOrder(Unit: UnitGD) -> void: # Lower is higher priority
	match movement_order.size():
		0: movement_order.append(Unit)
		1: movement_order.insert(int(movement_order[0].ai.aic > Unit.ai.aic), Unit)
		_:
			if !movement_order[0].ai.aic >= Unit.ai.aic:
				var is_inserted: bool = false
				for i in range(movement_order.size() - 1):
					if movement_order[i].ai.aic <= Unit.ai.aic and Unit.ai.aic <= movement_order[i + 1].ai.aic:
						movement_order.insert(i + 1, Unit)
						is_inserted = true
						break
				if !is_inserted: movement_order.append(Unit)
			else: movement_order.insert(0, Unit)
