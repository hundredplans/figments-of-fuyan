class_name TilesGD
extends Node3D
const MAX_HEIGHT: int = 11

signal console_tile_selected

var Combat: CombatGD
var VFX: VFXGD
var SpectateCamera: Node3D
var LevelUI: LevelUIGD
var LevelMap: LevelMapGD
var Vision: VisionGD
var Units: UnitsGD
var Lights: LightsGD
var Hand: HandGD
var PlayerManager: PlayerManagerGD
var GameEffects: GameEffectsGD
var ObjectManager: ObjectManagerGD
var UniqueTiles: UniqueTilesGD

var cube_directions: Array[Vector3] = [
Vector3(1, 0, -1),
Vector3(1, -1, 0),
Vector3(0, -1, 1),
Vector3(-1, 0, 1),
Vector3(-1, 1, 0),
Vector3(0, 1, -1)
]
const IS_TYPE: Dictionary = {
	"Enemy": 1,
	"Spawn": 2,
}

func cube_directions_by_distance(x: Vector3, distance: int) -> Vector3:
	return x * distance

func onRotateAroundCenter(x: Vector4) -> Vector4:
	return Vector4(-x.z, -x.x, -x.y, x.w)

# This class always takes tiles not positions and return you the tiles but works with positions internally
func is_neighbour(Tile: TileGD, _Tile: TileGD, distance: int = 1, search_elevation: bool = false) -> bool:
	return _is_neighbour(Tile.onTTpos(), _Tile.onTTpos(), distance, search_elevation)
	
func _is_neighbour(pos: Vector4, opos: Vector4, distance: int = 1, search_elevation: bool = false) -> bool:
	return (search_elevation or pos.w == opos.w) and \
	abs(pos.x - opos.x) + abs(pos.y - opos.y) + abs(pos.z - opos.z) == distance * 2
	
func all_neighbours(Tile: TileGD, distance: int = 1, search_elevation: bool = false, tiles: Array = get_children()) -> Array:
	return positions_to_tiles(_all_neighbours(Tile.onTTpos(), distance, search_elevation, tiles_to_positions(tiles)))
	
func _all_neighbours(pos: Vector4, distance: int = 1, search_elevation: bool = false, poses: Array = get_children_positions()) -> Array:
	return poses.filter(_is_neighbour.bind(pos, distance, search_elevation))
	
func all_neighbours_tiles(tiles: Array, otiles: Array = get_children(), distance: int = 1, search_elevation: bool = false) -> Array:
	var tiles_set: Dictionary = {}
	for Tile in tiles: 
		for _Tile in all_neighbours(Tile, distance, search_elevation, otiles):
			tiles_set.merge({_Tile: null})
	return tiles_set.keys()

func tiles_intersection(tiles: Array, otiles: Array) -> Array:
	return tiles.filter(is_tile_in_tiles.bind(otiles))

func all_in_range(Tile: TileGD, distance: int = 2, include_central: bool = false, tiles: Array = get_children()) -> Array:
	if !include_central: tiles.erase(Tile)
	return tiles.filter(func(x: TileGD): return tile_distance(Tile, x) <= distance)
	
func getTposInRange(Tile: TileGD, i: int = 1) -> Array:
	var tposes: Array = []
	for x in range(-i, (i + 1)):
		for y in range(max(-i, -x - i), min(i, -x + i) + 1):
			tposes.append(Vector3(x, y, -x - y) + Tile.tpos)
	return tposes

func tiles_unique(tiles: Array, otiles: Array) -> Array:
	return tiles.filter(is_tile_not_in_tiles.bind(otiles))

func is_tile_not_in_tiles(Tile: TileGD, tiles: Array) -> bool: return Tile not in tiles
func is_tile_in_tiles(Tile: TileGD, tiles: Array) -> bool: return Tile in tiles

func get_children_positions() -> Array: return get_children().map(tile_to_position)
func tile_to_position(Tile: TileGD) -> Vector4: return Tile.onTTpos()
func tiles_to_positions(tiles: Array) -> Array: return tiles.map(tile_to_position)

func positions_to_tiles(tiles: Array) -> Array: return tiles.map(position_to_tile)

func nonexistent_positions_above(Tile: TileGD) -> Array: #TASK: Optimise this
	var pos: Vector4 = Tile.onTTpos()
	var positions: Array = range(1, MAX_HEIGHT).map(func(x: int): return Vector4(pos.x, pos.y, pos.z, pos.w + x))
	var return_positions: Array = []
	for _pos in positions: # necessary for loop or it will ignore ceiling tiles
		if is_nonexistent_valid_pos(_pos): return_positions.append(_pos)
		else: break
	return return_positions

func is_nonexistent_valid_pos(pos: Vector4) -> bool:
	return pos.w < MAX_HEIGHT and pos not in get_children_positions()

func onIsTileJumpableThrough(pos: Vector4) -> bool:
	for _pos in get_children_positions():
		if pos == _pos:
			var Tile: TileGD = position_to_tile(pos)
			return !(Tile.tile.id > 0 or Tile.solid_status > 0)
	return true

func position_to_tile(pos: Vector4) -> Node3D:
	var positions: Array = get_children_positions()
	for i in range(positions.size()):
		if positions[i] == pos: return get_child(i)
	return null

func on_is_type_get_tiles(is_type: String, type: String) -> Array:
	return get_children().filter(on_match_type.bind(is_type, type))
	
func on_match_type(Tile: TileGD, is_type: String, type: String) -> bool:
	return Tile[type].id == IS_TYPE[is_type]
	
func on_find_tile_primary_type(Tile: TileGD) -> String:
	match Tile.obj.id:
		1: return "SpawnEnemy"
		2: return "Spawn"
	return "Regular"

func from_center_concentric(distance: int = 1, otiles: Array = get_children(), elevation: int = 0, search_elevation: bool = false):
	return all_neighbours(position_to_tile(Vector4(0, 0, 0, elevation)), distance, search_elevation, otiles)

func neighbour_rotation(Tile: TileGD, _Tile: TileGD) -> int:
	var direction: Variant = _Tile.onTTpos() - Tile.onTTpos()
	var distance: int = tile_distance(Tile, _Tile)
	
	if distance == 1:
		direction = Vector3(direction.x, direction.y, direction.z)
		for i in range(cube_directions.size()):
			if cube_directions[i] == direction:
				return i
	elif distance > 1:
		var each_tile_distance: Array = []
		for i in range(cube_directions.size()):
			var new_pos: Vector3 = cube_directions[i] + Tile.tpos
			each_tile_distance.append([i, _tile_distance(_Tile.tpos - new_pos)])
		each_tile_distance.sort_custom(func(x: Array, y: Array): return x[1] < y[1])
		return each_tile_distance[0][0]
			
	return 0

func all_diagonals(Tile: TileGD, distance: int = 1, tiles: Array = get_children(), search_elevation: bool = false) -> Array:
	return positions_to_tiles(_all_diagonals(Tile.onTTpos(), tiles_to_positions(tiles), distance, search_elevation))
	
func _all_diagonals(pos: Vector4, poses: Array = get_children_positions(), distance: int = 1, search_elevation: bool = false) -> Array:
	return poses.filter(_is_diagonal.bind(pos, distance, search_elevation))
	
func is_diagonal(Tile: TileGD, _Tile: TileGD, distance: int = 1, search_elevation: bool = false) -> bool:
	return _is_diagonal(Tile.onTTpos(), _Tile.onTTpos(), distance, search_elevation)
	
func _is_diagonal(pos: Vector4, opos: Vector4, distance: int = 1, search_elevation: bool = false) -> bool:
	return (search_elevation or pos.w == opos.w) and \
	Vector3(pos.x, pos.y, pos.z) - Vector3(opos.x, opos.y, opos.z) in \
	cube_directions.map(cube_directions_by_distance.bind(distance))

func admin_highlight_tiles(tiles: Array) -> void:
	for tile in tiles: tile.visible = false

func tile_by_unit(Unit: UnitGD) -> TileGD:
	return Unit.Tile
	
func get_children_by_elevation(w: int = 0) -> Array:
	var positions: Array = []
	for pos in get_children_positions():
		if pos.w == w: positions.append(pos)
	return positions_to_tiles(positions)
	
func _tile_distance(pos: Vector3) -> int:
	return (abs(pos.x) + abs(pos.y) + abs(pos.z)) / 2
	
func tile_distance(Tile: TileGD, _Tile: TileGD) -> int:
	return _tile_distance(Tile.tpos - _Tile.tpos)
	
func onTilesInVisionRange(Tile: TileGD, VISION_RANGE: int) -> Array:
	var tposes: Array = getTposInRange(Tile, VISION_RANGE)
	return get_children().filter(func(x: TileGD): return x.tpos in tposes)
	
# -----------------

func _ready() -> void:
	LevelUI.mouse_in_ui.connect(on_mouse_enters_ui)
	LevelMap.input_lock_updated.connect(onInputLockUpdated)
	on_set_default_shader_parameters()

var active_tile: TileGD
func on_tile_mouse_entered(Tile: TileGD) -> void:
	active_tile = Tile
	onTileHovered(active_tile)
	
func on_tile_mouse_exited(Tile: TileGD) -> void:
	active_tile = null
	on_tile_unhovered(Tile)

func tiles_by_tile_state(tile_state: String) -> Array:
	return get_children().filter(func(x: TileGD): return tile_state in x.tile_state)

func _process(_delta: float) -> void:
	if (!LevelUI.is_mouse_in_ui):
		if active_tile != null and Input.is_action_just_released("LeftClick"):
			onTilePressed()
				
func onTilePressed() -> void:
	if !select_console:
		var Unit: UnitGD = Units.unit_by_tile(active_tile)
		if active_tile != null:
			if LevelMap.verifyLock():
				if "TargetAffect" in active_tile.tile_state:
					PlayerManager.onAbilitySelectTileSelected(active_tile)
				
				elif PlayerManager.AbilitySelected == null:
					if "PathHovered" in active_tile.tile_outlines: 
						PlayerManager.onBeginUnitMovement(active_tile)
				
					elif Unit != null and Unit.Tile in Vision.getTeamVision():
						if "EnemyInRange" not in active_tile.tile_outlines: PlayerManager.on_occupied_tile_inspected(active_tile)
						else: PlayerManager.onBeginUnitMovement(active_tile)
				
			elif LevelMap.verifyLock(LevelMap.HAND_EXCLUSIVE) and on_find_tile_primary_type(active_tile) == "Spawn":
				VFX.onRemoveSpawnParticle(active_tile)
				Hand.on_card_placed(active_tile)
	else: console_tile_selected.emit(active_tile)

func onSpawnTiles(team_relation := TeamRelationGD.new()) -> Array:
	match team_relation.onTeam():
		0: return get_children().filter(func(x: TileGD): return on_find_tile_primary_type(x) == "Spawn")
		1: return get_children().filter(func(x: TileGD): return on_find_tile_primary_type(x) == "SpawnEnemy")
	return []

func allNeighboursFast(Tile: TileGD, distance: int, tiles: Array) -> Array:
	return tiles.filter(func(x: TileGD): return tile_distance(x, Tile) == distance)

var is_stair_object: Array = [5]
func on_tiles_by_adjacent(tiles: Array = get_children(), astar: AStar3D = null) -> Dictionary:
	var by_adjacent: Dictionary = {}
	for Tile in tiles:
		by_adjacent[Tile] = allNeighboursFast(Tile, 1, tiles)
		astar.add_point(Tile.get_instance_id(), Tile.position)
	return by_adjacent

# ----------------- Tiles UI

func onStartPhaseStart() -> void:
	onConvertMultiTilePositions()
	onCreateTopOfCliffWall()
	onSetupTiles()
	onSetFneighbourTiles()
	onSetupObjectHighlight()
	
func onSetupObjectHighlight() -> void:
	for Tile in get_children():
		Tile.onSetupObjectHighlight()
		ObjectManager.onAddInteractableObj(Tile)
		ObjectManager.setDestructableObj(Tile)
func onCreateTopOfCliffWall() -> void:
	for Tile in get_children():
		if Tile.tile.id > 0:
			for w in range(Tile.w - 1, -1, -1):
				var _Tile: TileGD = position_to_tile(Vector4(Tile.tpos.x, Tile.tpos.y, Tile.tpos.z, w))
				if _Tile != null and _Tile.wall.id > 0: Tile.top_of_cliff_wall.append(_Tile)
				else: break
	
func onSetupTiles() -> void:
	var unique_tile_ids: Array = UniqueTiles.all_tiles.map(func(x: UniqueTileInfoGD): return x.id)
	for Tile in get_children():
		Helper.onCreateChildReferences(Tile)
		for type in Helper.BTAB_TO_TYPE[-1]:
			@warning_ignore("incompatible_ternary")
			Tile[type].model = null if type != "wall" else []
			
		for model in Tile.ModelManager.get_children():
			if model.type != "wall": Tile[model.type].model = model 
			else: Tile["wall"].model.append(model)
		
		setTileOutline(Tile, "")
		if Tile.solid_status == 1:
			for child in Tile.ModelManager.get_children().filter(func(x: Node3D): return x.type not in ["tile", "wall", "obj"]):
				for body in child.bodies:
					body.collision_layer = 16
					
		Tile.highlight_obj.connect(ObjectManager.onHighlightObj.bind(Tile))
		Tile.multi_tile_obj_hovered.connect(ObjectManager.onMultitileObjHovered.bind(Tile))
		if Tile.tile.id in unique_tile_ids: UniqueTiles.onAddUniqueTile(Tile)
	
func onRemovePathHovered(tiles: Array = get_children().filter(func(x: TileGD): return "PathHovered" in x.tile_outlines)) -> void:
	if PlayerManager.getUnitSelected() != null:
		for _Tile in tiles: setTileOutline(_Tile, "PathHovered", true)
	
func onConvertMultiTilePositions() -> void:
	for Tile in get_children():
		for type in Helper.BTAB_TO_TYPE[-1]:
			Tile[type].multi_tile = Tile[type].multi_tile\
			.map(func(x: Array): return position_to_tile(Vector4(x[0], x[1], x[2], x[3])))\
			.filter(func(x: TileGD): return x != null)
	
func onRemoveTileBlockedByHeight(Tile: TileGD, height: float) -> bool:
	# 1 = 1.2 (the bottom)
	# 2 = 2.4 (the bottom)
	var bot_range: float = getUnitPositionOnTile(Tile).y
	var top_range: float = bot_range + height
	for w in range(Tile.w + 1, ceil(top_range / 1.2) + 1):
		var _Tile: TileGD = position_to_tile(Tile.onTTpos(w))
		if _Tile != null: return false
	return true
	
func onRemoveTilesBlockedByHeight(tiles: Array, Unit: UnitGD) -> Array:
	return tiles.filter(onRemoveTileBlockedByHeight.bind(Unit.height.top))

func on_can_ramp_connect(Tile: TileGD, _Tile: TileGD, hdiff: int) -> bool:
	if abs(hdiff) == 1: # ensures it's from a regular tile
		var stair_or_tile_rot: int = (_Tile.obj.rotation) if (_Tile.obj.id in is_stair_object) else (_Tile.tile.rotation)
		var neirot: int = neighbour_rotation(Tile, _Tile) 
		return neirot == (stair_or_tile_rot + 1) % 6 or neirot == (stair_or_tile_rot + 4) % 6
	return false

func getUnitPositionOnTile(Tile: TileGD):
	var pos: Vector3 = Tile.global_position
	pos.y += 0.6 if is_ramp_tile(Tile) else 0.0
	return pos

func is_ramp_tile(Tile: TileGD) -> bool:
	return Tile.obj.id in is_stair_object or Tile.tile.type > 0

func getUnitAdjustedHeight(Tile: TileGD) -> float:
	return (Tile.w * 1.2) + (0.9 if is_ramp_tile(Tile) else 0.3)

func getTileById(id: int, tiles: Array = get_children()) -> TileGD:
	for Tile in tiles: if Tile.id == id: return Tile
	return null
			
func onSetFneighbourTiles() -> void:
	for Tile in get_children():
		for fneighbour in Tile.fneighbours:
			fneighbour.Tile = getTileById(fneighbour.id)
			
func onConnectPoints(Tile: TileGD, fneighbour: FneighbourGD, astar: AStar3D) -> void:
	if !(fneighbour.is_solid or fneighbour.movement_type == FneighbourGD.UNPASSABLE):
		astar.connect_points(Tile.id, fneighbour.Tile.id, false)
			
func onCreateMovementPaths(Unit: UnitGD,  speed: int = -1) -> Array: # Returns array of movement path
	if speed == -1: speed = Unit.speed
	if GameEffects.onGameFXExists(Unit, GameFXGD.DAZE): speed = 0
	var all_tiles: Dictionary = onCreateAllTiles(Unit, speed)
	var astar: AStar3D = onCreateAStar(all_tiles)
	var movement_paths: Array = onCreateOptimalPaths(Unit, all_tiles, astar, speed)
	return movement_paths

func onCreateAStar(all_tiles: Dictionary) -> AStar3D:
	var astar := AStar3D.new()
	for Tile in all_tiles.full_tiles:
		for fneighbour in Tile.fneighbours:
			astar.add_point(fneighbour.Tile.id, fneighbour.Tile.position)
		astar.add_point(Tile.id, Tile.position)
		
	for Tile in all_tiles.full_tiles:
		for fneighbour in Tile.fneighbours:
			onConnectPoints(Tile, fneighbour, astar)
			
	return astar

func onKillMovementPaths(Unit: UnitGD, movement_paths: Array) -> Array:
	return movement_paths.filter(func(x: MovementPathGD):\
	return x.DestinationTile.Unit != null and Combat.onCalculateDamage(x.DestinationTile.Unit, Unit) >= x.DestinationTile.Unit.health)

func onCreateOptimalPaths(Unit: UnitGD, all_tiles: Dictionary, astar: AStar3D, speed: int) -> Array:
	var movement_paths: Array = []
	var ally_vision: Array = Vision.getTeamVision()
	for Tile in all_tiles.full_tiles:
		var movement_path := MovementPathGD.new(Unit.Tile)
		var valid_path: bool = false
		var reconnections: Array = [] # [[p1, p2], [p1, p2]]
		while(!valid_path):
			var fall_damages: Dictionary = {}
			var tile_path: Array = Array(astar.get_id_path(Unit.Tile.id, Tile.id)).map(func(x: int): return getTileById(x))
			
			if tile_path.size() > 1 and tile_path.size() - 2 > speed:
				onDisconnectReconnectTiles(tile_path[tile_path.size() - 2], tile_path[tile_path.size() - 1]\
				,reconnections, astar)
				continue
				
			if tile_path.size() <= 1: break
			var fn_path: Array = onCreateFneighbourTilePath(Unit.Tile, tile_path)
			valid_path = onFneighbourPathValid(Unit, fn_path, astar, fall_damages, reconnections, speed, movement_path, ally_vision)
			if valid_path:
				movement_path.DestinationTile = fn_path[fn_path.size() - 1].Tile
				movement_path.fall_damages = fall_damages
				movement_path.fneighbours = fn_path
				movement_paths.append(movement_path)
		for points in reconnections: astar.connect_points(points[0], points[1], false)
	return movement_paths

func onFneighbourPathValid(Unit: UnitGD, fn_path: Array, astar: AStar3D, fall_damages: Dictionary, reconnections: Array, speed: int, movement_path: MovementPathGD, ally_vision: Array) -> bool:
	if onFneighbourPathValidUnitHeightHigh(Unit, fn_path, astar, reconnections):
		if onFneighbourPathValidDeath(Unit, fn_path, astar, fall_damages, reconnections):
			if onFneighbourPathValidEnemy(Unit, fn_path, astar, reconnections, movement_path, ally_vision):
				if onFneighbourPathValidDistance(Unit, fn_path, astar, reconnections, speed):
					return true
	return false

func onFnPathHasDeepWater(fn_path: Array) -> bool:
	for i in range(fn_path.size() - 1):
		if fn_path[i].Tile.isDeepWater(): return true
	return false

func onFneighbourPathValidDistance(Unit: UnitGD, fn_path: Array, astar: AStar3D, reconnections: Array, speed: int) -> bool:
	if !Unit.Tile.isDeepWater() and onFnPathHasDeepWater(fn_path): speed -= 1
	if fn_path.size() <= speed or (fn_path.size() <= speed + 1 and fn_path[fn_path.size() - 1].Tile.Unit != null):
		return true
	return onDisconnectReconnect(Unit, fn_path, fn_path.size() - 1, reconnections, astar)

func onFneighbourPathValidEnemy(Unit: UnitGD, fn_path: Array, astar: AStar3D, reconnections: Array, movement_path: MovementPathGD, ally_vision: Array) -> bool:
	for i in range(fn_path.size()):
		if fn_path[i].Tile.Unit != null: # if this can have ally units add a check for the team
			var fneighbour: FneighbourGD = fn_path[i]
			if i == fn_path.size() - 1 and (fneighbour.Tile.Unit.team == 0 or fneighbour.Tile in ally_vision):
				var EnemyUnit: UnitGD = fneighbour.Tile.Unit
				var a: float = getUnitAdjustedHeight(fneighbour.Tile)
				var b: float = a + EnemyUnit.height.top
				var c: float = getUnitAdjustedHeight(Unit.Tile)
				var d: float = c + Unit.height.top
				
				if onCalculateHdiff(Unit.Tile, fneighbour.Tile) == 0 or (a <= d and c <= b):
					movement_path.is_attack = true
					return true
			return onDisconnectReconnect(Unit, fn_path, i, reconnections, astar)
	return true

func onCalculateHdiff(Tile: TileGD, _Tile: TileGD) -> int:
	var h_one: int = abs(Tile.w * 2)
	if (Tile.tile.type in [1, 2]): h_one += 1
	var h_two: int = abs(_Tile.w * 2)
	if (_Tile.tile.type in [1, 2]): h_two += 1
	return abs(h_one - h_two)

func onDisconnectReconnectTiles(Tile: TileGD, _Tile: TileGD, reconnections: Array, astar: AStar3D) -> void:
	astar.disconnect_points(Tile.id, _Tile.id, false)
	reconnections.append([Tile.id, _Tile.id])

func onDisconnectReconnect(Unit: UnitGD, fn_path: Array, i: int, reconnections: Array, astar: AStar3D) -> bool:
	var Tile: TileGD = fn_path[i - 1].Tile if i > 0 else Unit.Tile
	onDisconnectReconnectTiles(Tile, fn_path[i].Tile, reconnections, astar)
	return false
	
func onFneighbourPathValidUnitHeightHigh(Unit: UnitGD, fn_path: Array, astar: AStar3D, reconnections: Array) -> bool:
	for i in range(fn_path.size()):
		if fn_path[i].unit_height <= Unit.height.top or fn_path[i].movement_type == FneighbourGD.HIGH:
			if !(i == fn_path.size() - 1 and fn_path[i].Tile.Unit != null):
				return onDisconnectReconnect(Unit, fn_path, i, reconnections, astar)
			return true
	return true
	
func onFneighbourPathValidDeath(Unit: UnitGD, fn_path: Array, astar: AStar3D, fall_damages: Dictionary, reconnections: Array) -> bool:
	var fall_damage: int = 0
	for i in range(fn_path.size()):
		fall_damage += onCalculateFallDamage(fn_path[i], fall_damages)
		if Combat.isFallDamageLethal(Unit, fall_damage) or (fn_path[i].Tile.isDeepWater() and onCanDrown(Unit)):
			if !(i == fn_path.size() - 1):
				return onDisconnectReconnect(Unit, fn_path, i, reconnections, astar)
			return true
	return true

func onCalculateFallDamage(fn: FneighbourGD, fall_damages: Dictionary) -> int:
	var dmg: int = 0
	if fn.hdiff >= 4:
		dmg = fn.hdiff - 3
		if fn.Tile.isShallowWater(): dmg /= 2
		elif fn.Tile.isDeepWater(): dmg = 0
	fall_damages[fn.Tile] = dmg
	return dmg

func onCreateFneighbourTilePath(Tile: TileGD, tile_path: Array) -> Array:
	var fn_path: Array = []
	var CurrentTile: TileGD = Tile
	for i in range(1, tile_path.size()):
		for fn in CurrentTile.fneighbours:
			if fn.Tile == tile_path[i]:
				CurrentTile = fn.Tile
				fn_path.append(fn)
				break
	return fn_path

func onCreateAllTiles(Unit: UnitGD, speed: int) -> Dictionary:
	var ally_vision: Array = Vision.getTeamVision()
	var in_speed_tiles: Array = all_in_range(Unit.Tile, speed, true)
	var enemy_tiles: Array = Units.on_units(TeamRelationGD.new(Unit.team, "Enemy")).map(func(x: UnitGD): return x.Tile)\
	.filter(func(x: TileGD): return x in ally_vision and tile_distance(x, Unit.Tile) <= Unit.speed + 1)
	
	for _Unit in Units.all_units():
		if !(Unit.team == 0 and _Unit.team == 1 and _Unit.Tile not in ally_vision):
			in_speed_tiles.erase(_Unit.Tile)
	in_speed_tiles.append(Unit.Tile)
	return {"full_tiles": enemy_tiles + in_speed_tiles, "enemy_tiles": enemy_tiles, "unit_tiles": Units.all_units().map(func(x: UnitGD): return x.Tile)}

func onUnits(team_relation: TeamRelationGD) -> Array:
	return Units.on_units(team_relation).map(func(x: UnitGD): return x.Tile)
	
func onCreatePathHovered(Tile: TileGD) -> MovementPathGD:
	if "MovementRange" in Tile.tile_outlines or "EnemyInRange" in Tile.tile_outlines:
		var movement_path := MovementPathGD.onFindTile(Tile, PlayerManager.unit_movement_paths)
		if movement_path != null:
			for fneighbour in movement_path.fneighbours:
				fneighbour.Tile.Effects.onSetHeightDropInfo(movement_path, fneighbour)
				setTileOutline(fneighbour.Tile, "PathHovered")
		return movement_path
	return null
func onTileHovered(Tile: TileGD) -> void:
	setTileOutline(Tile, "TileInspected")
	onCreatePathHovered(Tile)
	Vision.onTileHovered(Tile)
	onTileHoveredDisplayCard(Tile)
	
	if PlayerManager.ActiveUnit != null and SpectateCamera.SpectateUnit != PlayerManager.ActiveUnit and "MovementRange" in Tile.tile_outlines:
		LevelUI.setWarningText(true, "SkipAction")
	else: LevelUI.setWarningText()
	Tile.isMouseInTile(true)

func onTileHoveredDisplayCard(Tile: TileGD) -> void:
	if Tile in Vision.getTeamVision():
		LevelUI.onTileHoveredDisplayCard(Tile)
		
var InspectTile: TileGD

func on_tile_unhovered(Tile: TileGD) -> void:
	setTileOutline(Tile, "TileInspected", true)
	onRemovePathHovered()
	Vision.onTileUnhovered(Tile)
	LevelUI.onQueueTileHoveredGameCard()
	Tile.isMouseInTile(false)

const OUTLINE_INFO: Dictionary = {
	"EnemyInRange": [4, preload("res://assets/materials/tile_materials/tile_outlines/light_red_tile_outline.tres")],
	"PathHovered": [5, preload("res://assets/materials/tile_materials/tile_outlines/lgrey_tile_outline.tres")],
	"MovementRange": [3, preload("res://assets/materials/tile_materials/tile_outlines/grey_tile_outline.tres")],
	"TileInspected": [1, preload("res://assets/materials/tile_materials/tile_outlines/white_tile_outline.tres")],
	"AllyInspected": [2, preload("res://assets/materials/tile_materials/tile_outlines/green_tile_outline.tres")],
	"EnemyInspected": [2, preload("res://assets/materials/tile_materials/tile_outlines/red_tile_outline.tres")],
	"PastPath": [0, preload("res://assets/materials/tile_materials/tile_outlines/yellow_tile_outline.tres")],
	"": [-1, preload("res://assets/materials/tile_materials/tile_outlines/black_tile_outline.tres")],
}

func setTileOutline(Tile: TileGD, type: String, is_remove: bool = false) -> void:
	if is_remove: Tile.tile_outlines.erase(type)
	else: Tile.tile_outlines.append(type)
	
	var _highest: int = -1
	var highest: String = ""
	for _type in Tile.tile_outlines:
		if OUTLINE_INFO[_type][0] > _highest:
			highest = _type
			_highest = OUTLINE_INFO[_type][0]

	if highest == "TileInspected" and !is_remove:
		var Unit: UnitGD = Units.unit_by_tile(Tile)
		if Unit != null and (Unit.team == 0 or Unit.Tile in Vision.getTeamVision()):
			match Unit.team:
				0: highest = "AllyInspected"
				1: highest = "EnemyInspected"
				
	Tile.setOutline(OUTLINE_INFO[highest][1])
	Tile.Effects.onManageDeathPathLabel(PlayerManager.getUnitSelected(), type, is_remove)

var BASE_MATERIAL: Material = preload("res://assets/materials/tile_materials/base_tile_materials/base_tile_material.tres")
var TILE_MATERIALS: Dictionary
const TILE_MATERIAL_PATH: String = "res://assets/materials/tile_materials/tile_materials_resources/"

func on_set_default_shader_parameters() -> void:
	var regular_shader := preload("res://assets/materials/tile_materials/color_materials/tile_regular.gdshader")
	var regular_shader_unshaded := preload("res://assets/materials/tile_materials/color_materials/tile_regular_unshaded.gdshader")
	
	for file in Array(DirAccess.get_files_at(TILE_MATERIAL_PATH)).filter(func(x: String): return x.ends_with(".tres")):
		var tile_material: TileMaterial = load(TILE_MATERIAL_PATH + file)
		tile_material.material = load("res://assets/materials/tile_materials/color_materials/color_material.tres").duplicate()
		tile_material.material.shader = regular_shader if !tile_material.unshaded else regular_shader_unshaded
		tile_material.material.set_shader_parameter("albedo", tile_material.albedo)
		tile_material.material.set_shader_parameter("texture_albedo", load("res://assets/materials/base_materials/base_material.png"))
		
		TILE_MATERIALS.merge({tile_material.material_name: tile_material})
		match file.left(-5):
			"greyscale":
				tile_material.material.set_shader_parameter("specular", 0.0)
	
func on_remove_tile_material(Tile: TileGD, material_name: String = "") -> void:
	match material_name:
		"":
			if "Greyscale" in Tile.tile_state: Tile.tile_state = ["Greyscale"]
			else: Tile.tile_state = []
		"EmptyTile": Tile.tile_state = []
		_: Tile.tile_state.erase(material_name)
		
	on_set_tile_highest_material(Tile, 1 if material_name == "Greyscale" else 0)
	
func on_set_tile_material(Tile: TileGD, material_name: String):
	if !Tile.tile_state.has(material_name):
		Tile.tile_state.append(material_name)
	
	on_set_tile_highest_material(Tile, 2 if material_name == "Greyscale" else 0)

func on_set_tile_highest_material(Tile: TileGD, greyscale_state: int = 0) -> void: # 1 = removed, 2 = added
	var highest: int = 0
	for state in Tile.tile_state:
		var f: int = TILE_MATERIALS[state].priority
		if f > highest: highest = f
		
	match greyscale_state:
		1: Tile.setMaterial(BASE_MATERIAL, -2)
		2: Tile.setMaterial(TILE_MATERIALS["Greyscale"].material, -2)
	
	var mat: Material = getTileMaterialFromPriority(highest)
	Tile.setMaterial(mat, 0)
	
func getTileMaterialFromPriority(priority: int) -> Material:
	if priority > 0:
		for tile_material in TILE_MATERIALS.values():
			if tile_material.priority == priority:
				return tile_material.material
	return BASE_MATERIAL

func onInputLockUpdated() -> void:
	on_force_mouse_tile(!LevelMap.verifyLock(), 2)
	SpectateCamera.onChangeCameraMode(true)
		
var InputTile: TileGD
func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		on_mouse_entered(on_find_tile_by_raycast())
		
func on_mouse_enters_ui(x: bool) -> void:
	on_force_mouse_tile(x, 1)
	ObjectManager.onMouseEntersUI(x)

func on_force_mouse_tile(state: bool, override: int = 0) -> void:
	if state: on_mouse_entered(null, override)
	else: on_mouse_entered(on_find_tile_by_raycast(), override)

func on_mouse_entered(Tile: TileGD, override: int = 0) -> void:
	if ((!LevelUI.is_mouse_in_ui or override == 1) and (LevelMap.verifyLock(LevelMap.TILE_HOVER) or override == 2)):
		if InputTile != null and Tile != null and Tile != InputTile:
			on_tile_mouse_exited(InputTile)
			on_tile_mouse_entered(Tile)
		elif Tile == null and InputTile != null:
			on_tile_mouse_exited(InputTile)
		elif Tile != null and InputTile == null:
			on_tile_mouse_entered(Tile)
		InputTile = Tile

const RAY_LENGTH: int = 1000
func on_find_tile_by_raycast() -> TileGD:
	var to: Vector3 = SpectateCamera.Camera.project_ray_normal(get_viewport().get_mouse_position()) * RAY_LENGTH
	var ray: RayCast3D = Vision.MouseRayCast
	
	ray.position = SpectateCamera.Camera.position
	ray.target_position = to
	ray.force_raycast_update()
	
	if ray.is_colliding():
		return Helper.getTileFromCollision(ray.get_collider())
	return null

var select_console: bool = false
func onSelectTileConsoleMode() -> void:
	select_console = true

func onSelectTileFinish() -> void:
	select_console = false

func onFindUnitAdjacentTiles(Unit: UnitGD, distance: int) -> Array: #  Tiles based on unit's top height
	return getAdjacentTiles(Unit.Tile, distance, true).filter(_onFindUnitAdjacentTiles.bind(Unit))
	
func _onFindUnitAdjacentTiles(Tile: TileGD, Unit: UnitGD) -> bool:
	if Tile != null:
		var low_height: float = getUnitAdjustedHeight(Unit.Tile)
		var top_height: float = low_height + Unit.height.top
		var _Unit: UnitGD = Tile.Unit
		
		var low_other_height: float = getUnitAdjustedHeight(Tile)
		if _Unit != null:
			var top_other_height: float = low_other_height + _Unit.height.top
			return max(low_height, low_other_height) <= min(top_height, top_other_height)
		return low_other_height >= low_height and low_other_height < top_height
	return false
	
func onCanDrown(Unit: UnitGD) -> bool: return Unit.height.top < 1

func getAdjacentTiles(Tile: TileGD, distance: int = 1, search_elevation: bool = false, tiles: Array = get_children()) -> Array:
	var arr: Array = []
	for i in range(1, distance + 1): arr += all_neighbours(Tile, i, search_elevation, tiles)
	return arr
