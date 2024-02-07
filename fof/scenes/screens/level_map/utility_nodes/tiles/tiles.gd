class_name TilesGD
extends Node3D
const MAX_HEIGHT: int = 11

var LevelMap: LevelMapGD
var Vision: VisionGD
var Units: UnitsGD
var Lights: LightsGD
var Hand: HandGD

var cube_directions: Array[Vector3] = [Vector3(-1, 1, 0), Vector3(0, 1, -1), Vector3(1, 0, -1), Vector3(1, -1, 0), Vector3(0, -1, 1), Vector3(-1, 0, 1)]
const IS_TYPE: Dictionary = {
	"Enemy": 1,
	"Spawn": 2,
}

func cube_directions_by_distance(x: Vector3, distance: int) -> Vector3:
	return x * distance

# This class always takes tiles not positions and return you the tiles but works with positions internally
func is_neighbour(tile: Node3D, opos: Node3D, distance: int = 1, search_elevation: bool = false) -> bool:
	return _is_neighbour(tile.info.position, opos.info.position, distance, search_elevation)
	
func _is_neighbour(pos: Vector4, opos: Vector4, distance: int = 1, search_elevation: bool = false) -> bool:
	return (search_elevation or pos.w == opos.w) and \
	abs(pos.x - opos.x) + abs(pos.y - opos.y) + abs(pos.z - opos.z) == distance * 2
	
func all_neighbours(tile: Node3D, distance: int = 1, search_elevation: bool = false, tiles: Array = get_children()) -> Array:
	return positions_to_tiles(_all_neighbours(tile.info.position, distance, search_elevation, tiles_to_positions(tiles)))
	
func _all_neighbours(pos: Vector4, distance: int = 1, search_elevation: bool = false, poses: Array = get_children_positions()) -> Array:
	return poses.filter(_is_neighbour.bind(pos, distance, search_elevation))
	
func all_neighbours_tiles(tiles: Array, otiles: Array = get_children(), distance: int = 1, search_elevation: bool = false) -> Array:
	var tiles_set: Dictionary = {}
	for tile in tiles: 
		for otile in all_neighbours(tile, distance, search_elevation, otiles):
			tiles_set.merge({otile: null})
	return tiles_set.keys()

func tiles_intersection(tiles: Array, otiles: Array) -> Array:
	return tiles.filter(is_tile_in_tiles.bind(otiles))

func all_in_range(tile: Node3D, distance: int = 2, include_central: bool = false, search_elevation: bool = false, tiles: Array = get_children()) -> Array:
	return positions_to_tiles(_all_in_range(tile_to_position(tile), distance, include_central, search_elevation, tiles_to_positions(tiles)))

func _all_in_range(pos: Vector4, distance: int = 2, include_central: bool = false, search_elevation: bool = false, poses: Array = get_children_positions()) -> Array:
	var a: Array = []
	for n in range(1 - int(include_central), distance + 1):
		for _pos in _all_neighbours(pos, n, search_elevation, poses):
			a.append(_pos)
	return a

func tiles_unique(tiles: Array, otiles: Array) -> Array:
	return tiles.filter(is_tile_not_in_tiles.bind(otiles))

func is_tile_not_in_tiles(tile: Node3D, tiles: Array) -> bool: return tile not in tiles
func is_tile_in_tiles(tile: Node3D, tiles: Array) -> bool: return tile in tiles

func get_children_positions() -> Array: return get_children().map(tile_to_position)
func tile_to_position(tile: Node3D) -> Vector4: return tile.info.position
func tiles_to_positions(tiles: Array) -> Array: return tiles.map(tile_to_position)

func positions_to_tiles(tiles: Array) -> Array: return tiles.map(position_to_tile)

func nonexistent_positions_above(tile: Node3D) -> Array: #TASK: Optimise this
	var pos: Vector4 = tile_to_position(tile)
	var positions: Array = range(1, MAX_HEIGHT).map(func(x: int): return Vector4(pos.x, pos.y, pos.z, pos.w + x))
	var return_positions: Array = []
	for _pos in positions: # necessary for loop or it will ignore ceiling tiles
		if is_nonexistent_valid_pos(_pos): return_positions.append(_pos)
		else: break
	return return_positions

func is_nonexistent_valid_pos(pos: Vector4) -> bool:
	return pos.w < MAX_HEIGHT and pos not in get_children_positions()

func position_to_tile(pos: Vector4) -> Node3D: 
	var positions: Array = get_children_positions()
	for i in range(positions.size()):
		if positions[i] == pos: return get_child(i)
	return null

func on_is_type_get_tiles(is_type: String, type: String) -> Array:
	return get_children().filter(on_match_type.bind(is_type, type))
	
func on_match_type(tile: Node3D, is_type: String, type: String) -> bool:
	return tile.info[type].id == IS_TYPE[is_type]
	
func on_find_tile_primary_type(tile: Node3D) -> String:
	match tile.info.obj.id:
		2: return "Spawn"
	return "Regular"
	
func outside_neighbours(tiles: Array, otiles: Array = get_children(), distance: int = 1, search_elevation: bool = false) -> Array:
	return tiles_unique(all_neighbours_tiles(tiles, otiles, distance, search_elevation), tiles)

func from_center_concentric(distance: int = 1, otiles: Array = get_children(), elevation: int = 0, search_elevation: bool = false):
	return all_neighbours(position_to_tile(Vector4(0, 0, 0, elevation)), distance, search_elevation, otiles)

func neighbour_rotation(tile: Node3D, otile: Node3D, flip: bool = false) -> int:
	if is_neighbour(tile, otile):
		var direction: Variant = tile_to_position(tile) - tile_to_position(otile)
		direction = Vector3(direction.x, direction.y, direction.z)
		for i in range(cube_directions.size()):
			if cube_directions[i] == direction:
				if flip: return (i + 3) % 6
				return i
	return -1

func all_diagonals(tile: Node3D, distance: int = 1, tiles: Array = get_children(), search_elevation: bool = false) -> Array:
	return positions_to_tiles(_all_diagonals(tile_to_position(tile), tiles_to_positions(tiles), distance, search_elevation))
	
func _all_diagonals(pos: Vector4, poses: Array = get_children_positions(), distance: int = 1, search_elevation: bool = false) -> Array:
	return poses.filter(_is_diagonal.bind(pos, distance, search_elevation))
	
func is_diagonal(tile: Node3D, otile: Node3D, distance: int = 1, search_elevation: bool = false) -> bool:
	return _is_diagonal(tile_to_position(tile), tile_to_position(otile), distance, search_elevation)
	
func _is_diagonal(pos: Vector4, opos: Vector4, distance: int = 1, search_elevation: bool = false) -> bool:
	return (search_elevation or pos.w == opos.w) and \
	Vector3(pos.x, pos.y, pos.z) - Vector3(opos.x, opos.y, opos.z) in \
	cube_directions.map(cube_directions_by_distance.bind(distance))

func admin_highlight_tiles(tiles: Array) -> void:
	for tile in tiles: tile.visible = false

func is_tile_occupied_by_units(Tile: TileGD) -> bool:
	return Tile in Units.on_units().map(tile_by_unit)

func tile_by_unit(Unit: UnitGD) -> TileGD:
	return Unit.Tile
	
func get_children_by_elevation(w: int = 0) -> Array:
	var positions: Array = []
	for pos in get_children_positions():
		if pos.w == w: positions.append(pos)
	return positions_to_tiles(positions)
	
func tile_distance(Tile: TileGD, _Tile: TileGD) -> int:
	var pos: Vector4 = Tile.info.position - _Tile.info.position
	return (abs(pos.x) + abs(pos.y) + abs(pos.z)) / 2
	
# -----------------

func _ready() -> void:
	for child in get_children():
		child.get_node("MouseDetector").mouse_entered.connect(on_tile_mouse_entered.bind(child))
		child.get_node("MouseDetector").mouse_exited.connect(on_tile_mouse_exited.bind(child))
	on_set_default_shader_parameters()

var active_tile: TileGD
func on_tile_mouse_entered(Tile: TileGD) -> void:
	if !LevelMap.lock_inputs:
		active_tile = Tile
		on_tile_hovered(active_tile, on_find_tile_primary_type(Tile))
	
func on_tile_mouse_exited(Tile: TileGD) -> void:
	if !LevelMap.lock_inputs:
		active_tile = null
		on_tile_unhovered(Tile)

func tiles_by_tile_state(tile_state: String) -> Array:
	return get_children().filter(func(x: TileGD): return tile_state in x.tile_state)

func _process(_delta: float) -> void:
	if !LevelMap.lock_inputs:
		if active_tile != null and Input.is_action_just_pressed("LeftClick"):
			if is_tile_occupied_by_units(active_tile):
				Units.on_occupied_tile_inspected(active_tile)
			elif "PathHovered" in active_tile.tile_state:
				on_path_hovered_tile_selected(active_tile)
			elif on_find_tile_primary_type(active_tile) == "Spawn":
				Hand.on_card_placed(active_tile)

func tiles_in_speed(Unit: UnitGD) -> Array:
	return all_in_range(Unit.Tile, Unit.speed, true).filter(func(x: TileGD): return x.solid_status == 0)

func tile_path(begin: TileGD, end: TileGD, tiles: Array = get_children()) -> Array:
	var astar := AStar3D.new()
	var begin_id: int
	var end_id: int
	for i in range(tiles.size()): 
		astar.add_point(i, tiles[i].position)
		if begin == tiles[i]: begin_id = i
		elif end == tiles[i]: end_id = i
		
	for i in range(tiles.size()):
		for j in range(tiles.size()):
			if i != j and !astar.are_points_connected(i, j) and is_neighbour(tiles[i], tiles[j]):
				astar.connect_points(i, j)
	return Array(astar.get_id_path(begin_id, end_id)).map(func(x: int): return tiles[x])

# ----------------- Tiles UI

func on_tile_hovered(Tile: TileGD, type: String) -> void:
	if "MovementRange" not in Tile.tile_state and "UnitSelected" not in Tile.tile_state:
		on_set_tile_material(Tile, (type + "Inspected") if !is_tile_occupied_by_units(Tile) else "UnitInspected")
		
	elif "UnitSelected" not in Tile.tile_state: # create hovered tiles
		var starter_tile: TileGD = tiles_by_tile_state("UnitSelected")[0]
		
		path_hovered_tiles = tile_path(starter_tile, Tile, tiles_by_tile_state("MovementRange") + [starter_tile])
		path_hovered_tiles.remove_at(0)
		
		for _Tile in path_hovered_tiles:
			on_set_tile_material(_Tile, "PathHovered")

func on_tile_unhovered(Tile: TileGD) -> void:
	if "PathHovered" not in Tile.tile_state and "UnitSelected" not in Tile.tile_state:
		on_set_tile_material(Tile)
	elif "UnitSelected" not in Tile.tile_state: # remove all effects of hovered tiles
		for _Tile in tiles_by_tile_state("PathHovered"):
			on_set_tile_material(_Tile)

var path_hovered_tiles: Array
func on_path_hovered_tile_selected(Tile: TileGD) -> void:
	Units._on_unit_deselected(Units.UnitSelected)
	for _Tile in path_hovered_tiles:
		Units.move_to_tile(Units.UnitSelected, _Tile)
		if Tile == _Tile: break
		
var MATERIAL_NAME_TO_MATERIAL: Dictionary = {
	"RegularInspected": null,
	"SpawnInspected": null,
	"UnitSelected": null,
	"PathHovered": null,
	"MovementRange": null,
	"UnitInspected": null,
	"": null,
}
 
var MATERIAL_PRIORITIES: Array = ["", "MovementRange", "RegularInspected",
 "SpawnInspected", "UnitInspected", "PathHovered", "UnitSelected"]

var base_material: Material = preload("res://assets/materials/base_materials/base_material.tres")
func on_set_default_shader_parameters() -> void:
	for key in MATERIAL_NAME_TO_MATERIAL.keys():
		if key not in ["", "reset"]: 
			MATERIAL_NAME_TO_MATERIAL[key] = base_material.duplicate()
			MATERIAL_NAME_TO_MATERIAL[key].material_name = key
	
	MATERIAL_NAME_TO_MATERIAL["RegularInspected"].albedo_color = Color(1, 0, 0)
	MATERIAL_NAME_TO_MATERIAL["SpawnInspected"].albedo_color = Color(0, 1, 0)
	MATERIAL_NAME_TO_MATERIAL["MovementRange"].albedo_color = Color(1, 1, 0)
	MATERIAL_NAME_TO_MATERIAL["UnitSelected"].albedo_color = Color(0, 1, 1)
	MATERIAL_NAME_TO_MATERIAL["PathHovered"].albedo_color = Color(1, 0, 1)
	MATERIAL_NAME_TO_MATERIAL["UnitInspected"].albedo_color = Color(0, 0, 0)
	
func on_set_tile_material(Tile: TileGD, material_name: String = "", absolute_reset: bool = false, btab: int = 0):
	if material_name == "":
		if absolute_reset: Tile.tile_state = []
		else: Tile.tile_state.pop_back()
	else: Tile.tile_state.append(material_name)
	
	var highest: int = 0
	for tile_state in Tile.tile_state:
		var f: int = MATERIAL_PRIORITIES.find(tile_state)
		if f > highest: highest = f
	
	for type in Helper.BTAB_TO_TYPE[btab]:
		Tile.get(type).set_material(MATERIAL_NAME_TO_MATERIAL[MATERIAL_PRIORITIES[highest]])
