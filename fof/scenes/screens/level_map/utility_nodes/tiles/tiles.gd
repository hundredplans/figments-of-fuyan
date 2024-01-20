class_name TilesGD
extends Node3D

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
	
func all_neighbours(tile: Node3D, tiles: Array = get_children(), distance: int = 1, search_elevation: bool = false) -> Array:
	return positions_to_tiles(_all_neighbours(tile.info.position, tiles_to_positions(tiles), distance, search_elevation))
	
func _all_neighbours(pos: Vector4, poses: Array = get_children_positions(), distance: int = 1, search_elevation: bool = false) -> Array:
	return poses.filter(_is_neighbour.bind(pos, distance, search_elevation))
	
func all_neighbours_tiles(tiles: Array, otiles: Array = get_children(), distance: int = 1, search_elevation: bool = false) -> Array:
	var tiles_set: Dictionary = {}
	for tile in tiles: 
		for otile in all_neighbours(tile, otiles, distance, search_elevation):
			tiles_set.merge({otile: null})
	return tiles_set.keys()

func tiles_intersection(tiles: Array, otiles: Array) -> Array:
	return tiles.filter(is_tile_in_tiles.bind(otiles))

func tiles_unique(tiles: Array, otiles: Array) -> Array:
	return tiles.filter(is_tile_not_in_tiles.bind(otiles))

func is_tile_not_in_tiles(tile: Node3D, tiles: Array) -> bool: return tile not in tiles
func is_tile_in_tiles(tile: Node3D, tiles: Array) -> bool: return tile in tiles
func get_children_positions() -> Array: return get_children().map(tile_to_position)
func tile_to_position(tile: Node3D) -> Vector4: return tile.info.position
func tiles_to_positions(tiles: Array) -> Array: return tiles.map(tile_to_position)
func positions_to_tiles(tiles: Array) -> Array: return tiles.map(position_to_tile)
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
		1: return "Spawn"
	return "Regular"
	
func outside_neighbours(tiles: Array, otiles: Array = get_children(), distance: int = 1, search_elevation: bool = false) -> Array:
	return tiles_unique(all_neighbours_tiles(tiles, otiles, distance, search_elevation), tiles)

func from_center_concentric(distance: int = 1, otiles: Array = get_children(), elevation: int = 0, search_elevation: bool = false):
	return all_neighbours(position_to_tile(Vector4(0, 0, 0, elevation)), otiles, distance, search_elevation)

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

# -----------------

func _ready() -> void:
	for child in get_children():
		child.get_node("MouseDetector").mouse_entered.connect(on_tile_mouse_entered.bind(child))
		child.get_node("MouseDetector").mouse_exited.connect(on_tile_mouse_exited.bind(child))
		
var active_tile: Node3D
func on_tile_mouse_entered(tile: Node3D) -> void:
	active_tile = tile
	Lights.on_tile_hovered(active_tile, on_find_tile_primary_type(tile))
	
func on_tile_mouse_exited(__: Node3D) -> void:
	active_tile = null
	Lights.on_tile_unhovered()

func _input(_event: InputEvent) -> void:
	if active_tile != null and on_find_tile_primary_type(active_tile) == "Spawn" and Input.is_action_just_pressed("LeftClick"):
		Hand.on_card_placed(active_tile)

func on_clear_enemy_tiles() -> Array:
	var tiles: Array = on_is_type_get_tiles("Enemy", "obj")
	for Tile in tiles: Tile.obj.on_clear_enemy_tile()
	return tiles
