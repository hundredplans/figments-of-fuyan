class_name TilesGD
extends Node3D
const MAX_HEIGHT: int = 11

var Combat: CombatGD
var VFX: VFXGD
var SpectateCamera: Node3D
var LevelUI: LevelUIGD
var LevelMap: Node3D
var Vision: VisionGD
var Units: UnitsGD
var Lights: LightsGD
var Hand: HandGD
var PlayerManager: PlayerManagerGD

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
	
func outside_neighbours(tiles: Array, otiles: Array = get_children(), distance: int = 1, search_elevation: bool = false) -> Array:
	return tiles_unique(all_neighbours_tiles(tiles, otiles, distance, search_elevation), tiles)

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
	LevelMap.action_lock_changed.connect(onActionLockChanged)
	on_set_default_shader_parameters()

var active_tile: TileGD
func on_tile_mouse_entered(Tile: TileGD) -> void:
	active_tile = Tile
	on_tile_hovered(active_tile)
	
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
		if LevelMap.action_lock.is_empty() and "TargetAffect" in active_tile.tile_state:
			onTargetAffectPressed()
		
		if active_tile != null:
			if LevelMap.action_lock.is_empty() and "PathHovered" in active_tile.tile_outlines: 
				on_begin_unit_movement()
				
			elif Unit != null and Unit.Tile in Vision.getTeamVision():
				if "EnemyInRange" not in active_tile.tile_outlines:
					PlayerManager.on_occupied_tile_inspected(active_tile)
				elif LevelMap.action_lock.is_empty(): on_begin_unit_movement()
				
			elif LevelMap.action_lock == "SpawnVision" and on_find_tile_primary_type(active_tile) == "Spawn":
				VFX.onRemoveSpawnParticle(active_tile)
				Hand.on_card_placed(active_tile)
	else:
		console_sig.emit(active_tile)

func onSpawnTiles(team_relation := TeamRelationGD.new()) -> Array:
	match team_relation.onTeam():
		0: return get_children().filter(func(x: TileGD): return on_find_tile_primary_type(x) == "Spawn")
		1: return get_children().filter(func(x: TileGD): return on_find_tile_primary_type(x) == "SpawnEnemy")
	return []

func onTargetAffectPressed() -> void:
	Combat.onTargetAbility(PlayerManager.TAbilityUnit, PlayerManager.TAbility, active_tile)

func on_begin_unit_movement() -> void:
	var enemy_is_in_range: bool = "EnemyInRange" in active_tile.tile_outlines
	var Unit: UnitGD = PlayerManager.UnitSelected
	if enemy_is_in_range: 
		var active_index: int = path_hovered_info.tiles.find(active_tile)
		if active_index > -1:
			path_hovered_info.tiles.remove_at(active_index)
			path_hovered_info.types.remove_at(active_index)
	on_path_hovered_tile_selected(active_tile)
	if enemy_is_in_range: on_enemy_found_tile_selected(active_tile, Unit)

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

func on_start_phase_start() -> void:
	onConvertMultiTilePositions()
	onCreateTopOfCliffWall()
	onSetupTiles()
	onSetFneighbourTiles()
	
func onCreateTopOfCliffWall() -> void:
	for Tile in get_children():
		if Tile.tile.id > 0:
			for w in range(Tile.w - 1, -1, -1):
				var _Tile: TileGD = position_to_tile(Vector4(Tile.tpos.x, Tile.tpos.y, Tile.tpos.z, w))
				if _Tile != null and _Tile.wall.id > 0: Tile.top_of_cliff_wall.append(_Tile)
				else: break
	
func onSetupTiles() -> void:
	for Tile in get_children():
		Tile.Tiles = self
		for type in Helper.BTAB_TO_TYPE[-1]:
			@warning_ignore("incompatible_ternary")
			Tile[type].model = null if type != "wall" else []
			
		for model in Tile.ModelManager.get_children():
			if model.type != "wall": Tile[model.type].model = model 
			else: Tile["wall"].model.append(model)
		
		setTileOutline(Tile, "")
		if Tile.solid_status == 1:
			for child in Tile.ModelManager.get_children().filter(func(x: Node3D): return x.type not in ["tile", "wall"]):
				child.body.collision_layer = 16
	
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
			
func _onCreateMovementPaths(Unit: UnitGD,  speed: int = -1) -> Array: # Returns array of movement paths
	var f: float = Time.get_ticks_msec()
	if speed == -1: speed = Unit.speed
	var all_tiles: Dictionary = onCreateAllTiles(Unit, speed)
	var astar: AStar3D = onCreateAStar(all_tiles.full_tiles)
	var movement_paths: Array = onCreateOptimalPaths(Unit, all_tiles, astar)
	print(movement_paths)
	print(abs(f - Time.get_ticks_msec()))
	print()
	return movement_paths

func onCreateAStar(full_tiles: Array) -> AStar3D:
	var astar := AStar3D.new()
	var unit_tiles: Array = Units.all_units().map(func(x: UnitGD): return x.Tile)
	for Tile in full_tiles: astar.add_point(Tile.id, Tile.position)
	for Tile in full_tiles:
		for fneighbour in Tile.fneighbours:
			fneighbour.Tile = getTileById(fneighbour.id)
			onConnectPoints(Tile, fneighbour, astar)
	return astar

func onCreateOptimalPaths(Unit: UnitGD, all_tiles: Dictionary, astar: AStar3D) -> Array:
	var movement_paths: Array = []
	for Tile in all_tiles.full_tiles:
		var movement_path := MovementPathGD.new(Unit.Tile)
		var valid_path: bool = false
		var reconnections: Array = [] # [[p1, p2], [p1, p2]]
		while(!valid_path):
			var fall_damages: Dictionary = {}
			var tile_path: Array = Array(astar.get_id_path(Unit.Tile.id, Tile.id)).map(func(x: int): return getTileById(x))
			if tile_path.size() <= 1: break
			var fn_path: Array = onCreateFneighbourTilePath(Unit.Tile, tile_path)
			valid_path = onFneighbourPathValid(Unit, fn_path, astar, fall_damages, reconnections, movement_path)
		
			if valid_path:
				movement_path.DestinationTile = fn_path[fn_path.size() - 1].Tile
				movement_path.fall_damages = fall_damages
				movement_path.fneighbours = fn_path
				movement_paths.append(movement_path)
				
		for points in reconnections: astar.connect_points(points[0], points[1], false)
	return movement_paths

func onFneighbourPathValid(Unit: UnitGD, fn_path: Array, astar: AStar3D, fall_damages: Dictionary, reconnections: Array, movement_path: MovementPathGD) -> bool:
	if onFneighbourPathValidUnitHeightHigh(Unit, fn_path, astar, reconnections):
		if onFneighbourPathValidFallDamage(Unit, fn_path, astar, fall_damages, reconnections):
			if onFneighbourPathValidEnemy(Unit, fn_path, astar, reconnections, movement_path):
				return true
	return false

func onFneighbourPathValidEnemy(Unit: UnitGD, fn_path: Array, astar: AStar3D, reconnections: Array, movement_path: MovementPathGD) -> bool:
	for i in range(fn_path.size()):
		if fn_path[i].Tile.Unit != null: # if this can have ally units add a check for the team
			if i == fn_path.size() - 1:
				var EnemyUnit: UnitGD = fn_path[i].Tile.Unit
				var a: float = getUnitAdjustedHeight(fn_path[i].Tile)
				var b: float = a + EnemyUnit.height.top
				var c: float = getUnitAdjustedHeight(Unit.Tile)
				var d: float = c + Unit.height.top
				
				if onCalculateHdiff(Unit.Tile, fn_path[i].Tile) == 0 or (a <= d and c <= b):
					return true
			return onDisconnectReconnect(Unit, fn_path, i, reconnections, astar)
	return true

func onCalculateHdiff(Tile: TileGD, _Tile: TileGD) -> int:
	var h_one: int = abs(Tile.w * 2)
	if (Tile.tile.type in [1, 2]): h_one += 1
	var h_two: int = abs(_Tile.w * 2)
	if (_Tile.tile.type in [1, 2]): h_two += 1
	return abs(h_one - h_two)

func onDisconnectReconnect(Unit: UnitGD, fn_path: Array, i: int, reconnections: Array, astar: AStar3D) -> bool:
	var Tile: TileGD = fn_path[i - 1].Tile if i > 0 else Unit.Tile
	astar.disconnect_points(Tile.id, fn_path[i].id, false)
	reconnections.append([Tile.id, fn_path[i].id])
	return false
	
func onFneighbourPathValidUnitHeightHigh(Unit: UnitGD, fn_path: Array, astar: AStar3D, reconnections: Array) -> bool:
	for i in range(fn_path.size()):
		if fn_path[i].unit_height < Unit.Tile.unit_height or fn_path[i].movement_type == FneighbourGD.HIGH:
			if !(i == fn_path.size() - 1 and fn_path[i].Tile.Unit != null):
				return onDisconnectReconnect(Unit, fn_path, i, reconnections, astar)
			return true
	return true
	
func onFneighbourPathValidFallDamage(Unit: UnitGD, fn_path: Array, astar: AStar3D, fall_damages: Dictionary, reconnections: Array) -> bool:
	var fall_damage: int = 0
	for i in range(fn_path.size()):
		fall_damage += onCalculateFallDamage(Unit, fn_path[i], fall_damages)
		if Combat.isFallDamageLethal(Unit, fall_damage):
			if !(i == fn_path.size() - 1):
				return onDisconnectReconnect(Unit, fn_path, i, reconnections, astar)
			return true
	return true

func onCalculateFallDamage(Unit: UnitGD, fn: FneighbourGD, fall_damages: Dictionary) -> int:
	var hdiff: int = abs(fn.hdiff * 0.5)
	var dmg: int = 0
	if hdiff > Unit.height.top: dmg = (hdiff - floor(Unit.height.top)) * 2
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
	
	for Tile in Units.all_units().map(func(x: UnitGD): return x.Tile):
		in_speed_tiles.erase(Tile)
	in_speed_tiles.append(Unit.Tile)
	return {"full_tiles": enemy_tiles + in_speed_tiles, "enemy_tiles": enemy_tiles, "unit_tiles": Units.all_units().map(func(x: UnitGD): return x.Tile)}

func onUnits(team_relation: TeamRelationGD) -> Array:
	return Units.on_units(team_relation).map(func(x: UnitGD): return x.Tile)

var movement_paths: Dictionary = {"tiles": []}
func onCreateMovementPaths(Unit: UnitGD, type: String = "Default") -> void:
	var tiles: Array = []
	match type:
		"Default": tiles = get_children()
		"EnemyVision": tiles = Vision.getTeamVision(TeamRelationGD.new(1))
		
		
	movement_paths = {"tiles": []}
	var ally_vision: Array = Vision.getTeamVision()
	var astar := AStar3D.new()
	var _enemy_tiles: Array = Units.on_units(TeamRelationGD.new(Unit.team, "Enemy")).filter(func(x: UnitGD): return x.Tile in ally_vision and tile_distance(x.Tile, Unit.Tile) <= Unit.speed + 1).map(func(x: UnitGD): return x.Tile)
	var _in_range_tiles: Array = all_in_range(Unit.Tile, Unit.speed, true, tiles).filter(func(x: TileGD): return x.solid_status == 0)
	for Tile in Units.all_units().filter(func(x: UnitGD): return x.Tile in ally_vision).map(func(x: UnitGD): return x.Tile): _in_range_tiles.erase(Tile)
	
	var full_tiles: Array = onRemoveTilesBlockedByHeight(_enemy_tiles + _in_range_tiles, Unit)
	full_tiles.append(Unit.Tile)
	
	var tiles_by_adjacent: Dictionary = on_tiles_by_adjacent(full_tiles, astar)
	var movement_types: Array = []
	# Takes roughly 7 msec
	# Takes around 40msec in total

	for Tile in tiles_by_adjacent.keys():
		for _Tile in tiles_by_adjacent[Tile]:
			var EnemyUnit: UnitGD = Units.unit_by_tile(_Tile)
			var hdiff: int = (_Tile.w * 2) + int(is_ramp_tile(_Tile)) - ((Tile.w * 2) + int(is_ramp_tile(Tile)))
			if EnemyUnit != null:
				if EnemyUnit.team != Unit.team and !Combat.isStaggered(Unit) and EnemyUnit.Tile in Unit.visible_tiles:
					var a: float = getUnitAdjustedHeight(EnemyUnit.Tile)
					var b: float = a + EnemyUnit.height.top
					var c: float = getUnitAdjustedHeight(Tile)
					var d: float = c + Unit.height.top
					
					if hdiff == 0 or (a <= d and c <= b):
						on_connect_points(astar, movement_types, Tile, _Tile, Vector2i(1, 0))
					
			elif (_Tile.obj.id in is_stair_object or _Tile.tile.type == 2):  # Move to ramp
				if on_can_ramp_connect(Tile, _Tile, hdiff):
					on_connect_points(astar, movement_types, Tile, _Tile, Vector2i(2, hdiff))
			elif (Tile.obj.id in is_stair_object or Tile.tile.type == 2): # start on ramp
				if on_can_ramp_connect(_Tile, Tile, hdiff):
					on_connect_points(astar, movement_types, Tile, _Tile, Vector2i.ZERO)
			
			elif Tile.tile.type == 1: # start on half tile
				if hdiff in [-1, 1]: # half tile to regular (jump up / down)
					if isValidJump(Tile, _Tile, Unit.height.top):
						on_connect_points(astar, movement_types, Tile, _Tile, Vector2i(3, 0))
				elif hdiff == 0: # half tile to half tile
					on_connect_points(astar, movement_types, Tile, _Tile, Vector2i.ZERO)
				elif hdiff < 0 and is_valid_tall_jump(Tile, _Tile, Unit.height.top): 
					on_connect_points(astar, movement_types, Tile, _Tile, Vector3i(4, hdiff, 0))
					
			elif hdiff == 1 and _Tile.tile.type == 1: # jump up from regular to half
				if isValidJump(Tile, _Tile, Unit.height.top):
					on_connect_points(astar, movement_types, Tile, _Tile, Vector2i(3, 0))
					
			elif hdiff < 0: # jump down from regular tile
				if hdiff == -1:
					if isValidJump(Tile, _Tile, Unit.height.top):
						on_connect_points(astar, movement_types, Tile, _Tile, Vector2i(3, 0))
				elif is_valid_tall_jump(Tile, _Tile, Unit.height.top):
					on_connect_points(astar, movement_types, Tile, _Tile, Vector3i(4, hdiff, 0))
			
			elif hdiff == 0: # movement between regular tiles
				on_connect_points(astar, movement_types, Tile, _Tile, Vector2i.ZERO)
	tiles_by_adjacent.erase(Unit.Tile)
	
	for Tile in tiles_by_adjacent.keys(): # disconnect all points that a unit can't get to
		onCalculateOptimalPath(Tile, Unit, astar, movement_types)
		
	for Tile in tiles_by_adjacent.keys():
		var path: Dictionary = on_create_true_path(Array(astar.get_id_path(Unit.Tile.get_instance_id(), Tile.get_instance_id()))\
		.map(func(x: int): return instance_from_id(x)), movement_types, Unit) # Creates paths of [[Tile, vec2(id)], [Tile, vec2(id)]]
			
		if path.size > 0 and path.size <= Unit.speed + int(path.types[path.size - 1].x == 1):
			movement_paths[Tile] = path
			movement_paths.tiles.append(Tile)
			
func onCalculateOptimalPath(Tile: TileGD, Unit: UnitGD, astar: AStar3D, movement_types: Array) -> void:
	var path: Array = Array(astar.get_id_path(Unit.Tile.get_instance_id(), Tile.get_instance_id()))
	var tile_path: Array = path.map(func(x: int): return instance_from_id(x))
	var size: int = tile_path.size()
	
	var ally_vision: Array = Vision.getTeamVision()
	for i in range(size):
		if i > 0 and i == size - 1:
			var EnemyUnit: UnitGD = Units.unit_by_tile(tile_path[i])
			if EnemyUnit != null and EnemyUnit.Tile in ally_vision:
				var id: int = tile_path[i].get_instance_id()
				for point in astar.get_point_connections(id):
					if point != tile_path[i - 1].get_instance_id():
						astar.disconnect_points(id, point)
						
	var total_damage: int = 0
	#if size > 2:
	for i in range(size):
		if i < tile_path.size() - 1:
			for tile_array in movement_types:
				if tile_array[0] == tile_path[i - 1] and tile_array[1] == tile_path[i] and tile_array[2].x == 4:
					total_damage += on_calculate_drop_damage(tile_array[2].y, Unit.height.top).z
					if total_damage >= Unit.health:
						astar.disconnect_points(tile_path[i].get_instance_id(), tile_path[i + 1].get_instance_id())
						onCalculateOptimalPath(Tile, Unit, astar, movement_types)
						return
			
func on_calculate_drop_damage(_hdiff: int, top_height: float) -> Vector3i:
	var hdiff: int = abs(_hdiff * 0.5)
	var dmg: int = 0
	if hdiff > top_height:
		dmg = (hdiff - floor(top_height)) * 2
	return Vector3i(4, _hdiff, dmg)

const JUMP_OFFSET: float = 0.3
func isValidJump(From: TileGD, To: TileGD, height: float) -> bool:
	if From.w < To.w:
		return onIsValidJumpTileAbove(height, From.onTTpos(From.w + ceil(height)))
	elif From.w > To.w:
		for w in range(From.w + 1 + int(From.tile.id == 1), From.w + floor(height) + 1):
			if !onIsTileJumpableThrough(To.onTTpos(w)):
				return false
		return onIsValidJumpTileAbove(height, To.onTTpos(From.w + ceil(height)))
	return true

func onIsValidJumpTileAbove(height: float, ttpos: Vector4) -> bool:
	if JUMP_OFFSET + height >= ceil(height):
		return onIsTileJumpableThrough(ttpos)
	return true

func is_valid_tall_jump(From: TileGD, To: TileGD, height: int) -> bool:
	if isValidJump(From, To, height):
		var to_pos: Vector4 = To.onTTpos()
		for Tile in range(to_pos.w + 1, From.w + 1).map(func(x: int): return position_to_tile(Vector4(to_pos.x, to_pos.y, to_pos.z, x))):
			if !(Tile == null or Tile.solid_status == 1): return false
		return true
	return false

func on_create_true_path(id_path: Array, movement_types: Array, Unit: UnitGD) -> Dictionary: # For eliminating Tiles
	var stack_health: int = Unit.health
	var true_path: Dictionary = {"tiles": [], "types": [], "size": 0}
	for i in range(id_path.size()):
		if stack_health > 0:
			if i > 0:
				for tile_array in movement_types:
					if tile_array[0] == id_path[i - 1] and tile_array[1] == id_path[i]:
						if tile_array[2].x == 4:
							tile_array[2] = on_calculate_drop_damage(tile_array[2].y, Unit.height.top)
							stack_health -= tile_array[2].z
						true_path.tiles.append(tile_array[1])
						true_path.types.append(tile_array[2])
						break
		else: return {"tiles": [], "types": [], "size": 0}
	true_path.size = true_path.tiles.size()
	return true_path
	
# 0 = MoveTile, 1 = AttackTile, 2 = ClimbInstant, 3 = Jump, 4 = Drop
func on_connect_points(astar: AStar3D, movement_types: Array, Tile: TileGD, _Tile: TileGD, type: Variant) -> void:
	movement_types.append([Tile, _Tile, type])
	astar.connect_points(Tile.get_instance_id(), _Tile.get_instance_id(), false)
	
func on_tile_hovered(Tile: TileGD) -> void:
	setTileOutline(Tile, "TileInspected")
	if PlayerManager.UnitSelected != null and movement_paths.has(Tile): # create hovered tiles
		path_hovered_info = movement_paths[Tile]
		for i in range(path_hovered_info.tiles.size()):
			path_hovered_info.tiles[i].Effects.hovered_type = path_hovered_info.types[i]
			setTileOutline(path_hovered_info.tiles[i], "PathHovered")
	Vision.onTileHovered(Tile)
	onTileHoveredDisplayCard(Tile)

func onTileHoveredDisplayCard(Tile: TileGD) -> void:
	if Tile in Vision.getTeamVision():
		LevelUI.onTileHoveredDisplayCard(Tile)
		
var InspectTile: TileGD

func on_tile_unhovered(Tile: TileGD) -> void:
	setTileOutline(Tile, "TileInspected", true)
	if PlayerManager.UnitSelected != null:
		for _Tile in get_children().filter(func(x: TileGD): return "PathHovered" in x.tile_outlines):
			setTileOutline(_Tile, "PathHovered", true)
	Vision.onTileUnhovered(Tile)
	LevelUI.onQueueTileHoveredGameCard()

const OUTLINE_INFO: Dictionary = {
	"EnemyInRange": [4, preload("res://assets/materials/tile_materials/tile_outlines/light_red_tile_outline.tres")],
	"PathHovered": [5, preload("res://assets/materials/tile_materials/tile_outlines/white_tile_outline.tres")],
	"MovementRange": [3, preload("res://assets/materials/tile_materials/tile_outlines/movement_range_tile_outline.tres")],
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
	Tile.Effects.onManageHeightDropLabel(PlayerManager.UnitSelected)

var path_hovered_info: Dictionary = {"tiles": [], "size": 0}
func on_path_hovered_tile_selected(Tile: TileGD) -> void:
	var OriginalTile: TileGD = PlayerManager.UnitSelected.Tile
	PlayerManager.on_select_active_unit(PlayerManager.UnitSelected)
	for i in range(path_hovered_info.tiles.size()):
		if path_hovered_info.types[i].x != 1:
			Units.movement_outline_tiles.append(path_hovered_info.tiles[i])
			Units.move_to_tile(PlayerManager.UnitSelected, path_hovered_info.tiles[i], path_hovered_info.types[i])
			path_hovered_info.tiles[i].Effects.onManageHeightDropLabel(PlayerManager.UnitSelected)
		elif Units.attack_enemy_or_target(PlayerManager.UnitSelected, path_hovered_info.tiles[i]): 
			Units.movement_outline_tiles.append(path_hovered_info.tiles[i])
		if Tile == path_hovered_info.tiles[i]: break
		
	on_remove_tile_material(OriginalTile, "" if path_hovered_info.tiles.size() == 1 and path_hovered_info.types[0].x == 1 else "EmptyTile")
	PlayerManager._on_unit_deselected(PlayerManager.UnitSelected, true)
		
func on_enemy_found_tile_selected(Tile: TileGD, Unit: UnitGD) -> void:
	if Tile != null and Units.attack_enemy_or_target(Unit, Tile):
		Units.movement_outline_tiles.append(Tile)

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

func onActionLockChanged(action_lock: String) -> void:
	on_force_mouse_tile(!action_lock.is_empty(), 2)
	SpectateCamera.onChangeCameraMode(true)
		
var InputTile: TileGD
func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		on_mouse_entered(on_find_tile_by_raycast())
		
func on_mouse_enters_ui(x: bool) -> void:
	on_force_mouse_tile(x, 1)

func on_force_mouse_tile(state: bool, override: int = 0) -> void:
	if state: on_mouse_entered(null, override)
	else: on_mouse_entered(on_find_tile_by_raycast(), override)

func on_mouse_entered(Tile: TileGD, override: int = 0) -> void:
	if ((!LevelUI.is_mouse_in_ui or override == 1) and (LevelMap.action_lock in ["", "SpawnVision", "HandRegular"] or override == 2)):
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
	
	var node: Node3D = ray.get_collider()
	if node:
		node = node.get_node("../../../..")
		if node is UnitGD: return node.Tile
	return node

var select_console: bool = false
var console_sig: Signal
func onSelectTileConsoleMode(sig: Signal) -> void:
	console_sig = sig
	select_console = true

func onSelectTileFinish() -> void:
	select_console = false

func onFindUnitAdjacentTiles(Unit: UnitGD, distance: int) -> Array: #  Tiles based on unit's top height
	var tiles: Array = []
	for w in range(0, 6):
		for tpos in _all_neighbours(Unit.Tile.onTTpos(w), distance):
			var Tile: TileGD = position_to_tile(tpos)
			var height: float = getUnitAdjustedHeight(Unit.Tile) + Unit.height.top
			if Tile != null:
				if w >= Unit.Tile.w: # intentional double if
					if getUnitAdjustedHeight(Tile) <= height:
						tiles.append(Tile)
				else:
					var _Unit: UnitGD = Units.unit_by_tile(Tile)
					if _Unit != null:
						# Check if unit height aligns
						if getUnitAdjustedHeight(_Unit.Tile) + _Unit.height.top >= height - Unit.height.top:
							tiles.append(Tile)
	return tiles
