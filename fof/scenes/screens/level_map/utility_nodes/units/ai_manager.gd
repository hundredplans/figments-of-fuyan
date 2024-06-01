class_name AIManagerGD
extends Node

var SpectateCamera: SpectateCameraGD
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
	invisible_movement_tracker = []
	active_movement_order = movement_order.duplicate()
	onMoveNextAIUnit()

func onMoveNextAIUnit() -> void:
	if active_movement_order.size() > 0:
		var Unit: UnitGD = active_movement_order.pop_front()
		Units.setUnitStatus(Unit, "TurnActive")
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
			if isPathSafe(Tiles.movement_paths[EnemyUnit.Tile]):
				onChosenPathSelected(Unit, Tiles.movement_paths[EnemyUnit.Tile])
				return
		else:
			var old_speed: int = Unit.speed
			Unit.speed = 5
			Tiles.onCreateMovementPaths(Unit, "EnemyVision")
			Unit.speed = old_speed
			if EnemyUnit.Tile in Tiles.movement_paths.keys():
				Tiles.movement_paths[EnemyUnit.Tile].size = Unit.speed
				if isPathSafe(Tiles.movement_paths[EnemyUnit.Tile]):
					onChosenPathSelected(Unit, Tiles.movement_paths[EnemyUnit.Tile])
					return
				
	Tiles.movement_paths = old_paths
	onChooseRandomMovementPath(Unit)

func isPathSafe(tile_path: Dictionary) -> bool:
	return tile_path['types'].all(func(x: Variant): return x.x != 4)

func onChooseRandomMovementPath(Unit: UnitGD) -> void:
	var movement_paths: Array = []
	for key in Tiles.movement_paths:
		if typeof(key) != TYPE_STRING and Tiles.movement_paths[key].size == Unit.speed:
			movement_paths.append(Tiles.movement_paths[key])
	
	movement_paths = movement_paths.filter(isPathSafe)
	if movement_paths.size() > 0:
		onChosenPathSelected(Unit, movement_paths[randi() % movement_paths.size()])
	else: onMoveNextAIUnit()
	
const FIRST_MOVE_DELAY: float = 0.3
func onChosenPathSelected(Unit: UnitGD, chosen_path: Dictionary) -> void:
	if chosen_path.size > 0:
		Tiles.on_remove_tile_material(Unit.Tile, "")
	
	var vis_array: Array = []
	await onCalculateVisibilityPath(Unit, chosen_path, vis_array)
	var pushed_delay: bool = false
	var j: int = 0
	for i in range(chosen_path.size):
		if !pushed_delay and vis_array.size() > 0 and vis_array[i].vis_path != "Invisible":
			var lambda: Callable = (func(): Unit.Model._look_at(chosen_path.tiles[i]); SpectateCamera.onSpectate(Unit))
			Units.onPushArgDelay(Unit, FIRST_MOVE_DELAY, SpectateCamera.onSpectate.bind(Unit), lambda)
			pushed_delay = true
		if chosen_path.types[i].x != 1: Units.onMoveToTileAI(Unit, chosen_path.tiles[i], chosen_path.types[i], vis_array, j); j += 1
		else: Units.attack_enemy_or_target(Unit, chosen_path.tiles[i])
	Units.onAIMoveFinisher(Unit, vis_array)

func onChosenPathVisPath(chosen_path: Dictionary, Unit: UnitGD, default_tile: TileGD, vision_path: Array, default_body_pos: Vector3, default_ray_pos: Vector3) -> void:
	var visions: Array = Units.all_units().map(func(x: UnitGD): return [x, x.visible_tiles.duplicate()])
	for i in range(chosen_path.size):
		if chosen_path.types[i].x != 1:
			var Tile: TileGD = chosen_path.tiles[i]
			var global: Vector3 = Tiles.getUnitPositionOnTile(Tile)
			Unit.Model.static_body.global_position = global + default_body_pos
			Unit.VisionRaycast.global_position = global + default_ray_pos
			Unit.Model._look_at_body(Tile)
			Unit.Tile = Tile
			await get_tree().process_frame
			var vision_info: Dictionary = Unit.onCalculateVisionInfo()
			Unit.visible_tiles = vision_info.visible_tiles
			Vision.onProcessUnitVision(Unit, vision_info.unit_vision, [], false)
			vision_path.append(vision_info)
	
	for info in visions:
		info[0].visible_tiles = info[1]
	
func onCalculateVisibilityPath(Unit: UnitGD, chosen_path: Dictionary, vis_array: Array = []) -> void:
	var default_rot: int = Unit.Model.rot
	var default_tile: TileGD = Unit.Tile
	var default_body_pos: Vector3 = Unit.Model.static_body.position
	var default_ray_pos: Vector3 = Unit.VisionRaycast.position
	
	await onChosenPathVisPath(chosen_path, Unit, default_tile, vis_array, default_body_pos, default_ray_pos)
	onCreateVisPath(vis_array)
	invisible_movement_tracker.append(onFindNonInvisibleMove(vis_array))
	Unit.onResetUnit(default_body_pos, default_ray_pos, default_rot, default_tile)

func onCreateVisPath(vis_array: Array) -> void:
	for vis_info in vis_array:
		var ally_intents: Array = vis_info.unit_vision.keys().filter(func(x: UnitGD): return x.team == 0).map(func(x: UnitGD): return vis_info.unit_vision[x])
		var path: String = "Invisible"
		if ally_intents.any(func(x: String): return x == "Regular"): path = "Regular"
		else:
			var any_enter: bool = ally_intents.any(func(x: String): return x == "Enter")
			var any_exit: bool = ally_intents.any(func(x: String): return x == "Exit")
			if any_exit and any_enter: path = "Regular"
			elif any_exit: path = "Exit"
			elif any_enter: path = "Enter"
		
		vis_info['vis_path'] = path

func onFindNonInvisibleMove(vis_array: Array) -> bool:
	for vision_info in vis_array:
		for _Unit in vision_info.unit_vision:
				if _Unit.team == 0 and vision_info.vis_path != "Invisible":
					return false
	return true

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
