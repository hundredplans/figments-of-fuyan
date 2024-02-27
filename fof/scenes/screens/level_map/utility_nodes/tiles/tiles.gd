class_name TilesGD
extends Node3D
const MAX_HEIGHT: int = 11

var SpectateCamera: Camera3D
var LevelUI: LevelUIGD
var LevelMap: LevelMapGD
var Vision: VisionGD
var Units: UnitsGD
var Lights: LightsGD
var Hand: HandGD

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

func neighbour_rotation(tile: Node3D, otile: Node3D) -> int:
	if is_neighbour(tile, otile, 1, true):
		var direction: Variant = tile_to_position(otile) - tile_to_position(tile)
		
		direction = Vector3(direction.x, direction.y, direction.z)
		for i in range(cube_directions.size()):
			if cube_directions[i] == direction:
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
	LevelUI.mouse_in_ui.connect(on_mouse_enters_ui)
	LevelMap.lock_inputs_changed.connect(on_lock_inputs_changed)
	for child in get_children():
		child.get_node("MouseDetector").mouse_entered.connect(on_tile_mouse_entered.bind(child))
		child.get_node("MouseDetector").mouse_exited.connect(on_tile_mouse_exited.bind(child))
	on_set_default_shader_parameters()

var TileInHopper: TileGD
var active_tile: TileGD
func on_tile_mouse_entered(Tile: TileGD, override: bool = false) -> void:
	if active_tile == null and Tile.visible and (!LevelUI.is_mouse_in_ui or override):
		if !LevelMap.lock_inputs:
			active_tile = Tile
			on_tile_hovered(active_tile, on_find_tile_primary_type(Tile))
		else: TileInHopper = Tile
	
func on_tile_mouse_exited(Tile: TileGD, override: bool = false) -> void:
	if active_tile != null and Tile.visible and (!LevelUI.is_mouse_in_ui or override):
		if !LevelMap.lock_inputs:
			active_tile = null
			on_tile_unhovered(Tile, on_find_tile_primary_type(Tile))
		else: TileInHopper = null

func tiles_by_tile_state(tile_state: String) -> Array:
	return get_children().filter(func(x: TileGD): return tile_state in x.tile_state)

func _process(_delta: float) -> void:
	if !LevelMap.lock_inputs:
		if active_tile != null and Input.is_action_just_released("LeftClick"):
			if is_tile_occupied_by_units(active_tile):
				Units.PlayerManager.on_occupied_tile_inspected(active_tile)
			elif "PathHovered" in active_tile.tile_state:
				on_begin_unit_movement()
			elif on_find_tile_primary_type(active_tile) == "Spawn":
				Hand.on_card_placed(active_tile)

func on_begin_unit_movement() -> void:
	var enemy_is_in_range: bool = active_tile.tile_state.has("EnemyInRange")
	var Unit: UnitGD = Units.PlayerManager.UnitSelected
	if enemy_is_in_range: 
		var active_index: int = path_hovered_info.tiles.find(active_tile)
		if active_index > -1:
			path_hovered_info.tiles.remove_at(active_index)
			path_hovered_info.types.remove_at(active_index)
	on_path_hovered_tile_selected(active_tile)
	if enemy_is_in_range: on_enemy_found_tile_selected(active_tile, Unit)

var is_stair_object: Array = [5]
func on_tiles_by_adjacent(tiles: Array = get_children(), astar: AStar3D = null) -> Dictionary:
	var by_adjacent: Dictionary = {}
	for Tile in tiles:
		by_adjacent[Tile] = all_neighbours(Tile, 1, true, tiles)
		astar.add_point(Tile.get_instance_id(), Tile.position)
	return by_adjacent

# ----------------- Tiles UI

func _on_remove_tiles_above_height(Tile: TileGD, height: int) -> bool:
	for i in range(Tile.info.position.w + 1, height + int(Tile.info.tile.type > 0 or Tile.info.obj.id in is_stair_object)):
		var _Tile: TileGD = position_to_tile(Vector4(Tile.info.position.x, Tile.info.position.y, Tile.info.position.z, Tile.info.position.w + i))
		if _Tile != null: return false
	return true

func on_remove_tiles_above_height(tiles: Array, height: int) -> Array:
	return tiles.filter(func(x: TileGD): return _on_remove_tiles_above_height(x, height))

func on_can_ramp_connect(Tile: TileGD, _Tile: TileGD, hdiff: int) -> bool:
	if abs(hdiff) == 1: # ensures it's from a regular tile
		var stair_or_tile_rot: int = (_Tile.info.obj.rotation) if (_Tile.info.obj.id in is_stair_object) else (_Tile.info.tile.rotation)
		var neirot: int = neighbour_rotation(Tile, _Tile) 
		return neirot == (stair_or_tile_rot + 1) % 6 or neirot == (stair_or_tile_rot + 4) % 6
	return false

func on_filter_in_range_tiles(x: TileGD):
	var Unit: UnitGD = Units.unit_by_tile(x)
	return x.solid_status == 0 or (Unit != null and Unit.team == 1)

var movement_paths: Dictionary = {"tiles": []}
func on_create_movement_paths(Unit: UnitGD) -> void:
	movement_paths = {"tiles": []}
	var astar := AStar3D.new()
	
	var _enemy_tiles: Array = all_neighbours(Unit.Tile, Unit.speed + 1, true)\
	.filter(func(x: TileGD): var _Unit: UnitGD = Units.unit_by_tile(x); return _Unit != null and _Unit.team == 1)
	var _in_range_tiles: Array = all_in_range(Unit.Tile, Unit.speed, true, true).filter(on_filter_in_range_tiles)
	
	var full_tiles: Array = on_remove_tiles_above_height(_enemy_tiles + _in_range_tiles, Unit.height + Unit.Tile.info.position.w)
	full_tiles.append(Unit.Tile)
	
	var tiles_by_adjacent: Dictionary = on_tiles_by_adjacent(full_tiles, astar)
	var movement_types: Array = []
	for Tile in tiles_by_adjacent.keys():
		for _Tile in tiles_by_adjacent[Tile]:
			var EnemyUnit: UnitGD = Units.unit_by_tile(_Tile)
			var hdiff: int = (_Tile.info.position.w * 2) + int(_Tile.info.tile.type > 0 or _Tile.info.obj.id in is_stair_object)\
			 - ((Tile.info.position.w * 2) + int(Tile.info.tile.type > 0 or Tile.info.obj.id in is_stair_object))
			if EnemyUnit != null:
				var enemy_hdiff: int = abs(int(hdiff * 0.5))
				if Unit.height - enemy_hdiff > 0 or EnemyUnit.height > enemy_hdiff:
					on_connect_points(astar, movement_types, Tile, _Tile, Vector2i(1, 0))
			elif (_Tile.info.obj.id in is_stair_object or _Tile.info.tile.type == 2):  # Move to ramp
				if on_can_ramp_connect(Tile, _Tile, hdiff):
					on_connect_points(astar, movement_types, Tile, _Tile, Vector2i(2, hdiff))
			elif (Tile.info.obj.id in is_stair_object or Tile.info.tile.type == 2): # start on ramp
				if on_can_ramp_connect(_Tile, Tile, hdiff):
					on_connect_points(astar, movement_types, Tile, _Tile, Vector2i.ZERO)
			elif Tile.info.tile.type == 1: # start on half tile
				if hdiff in [-1, 1]:
					on_connect_points(astar, movement_types, Tile, _Tile, Vector2i(3, 0))
				elif hdiff == 0:
					on_connect_points(astar, movement_types, Tile, _Tile, Vector2i.ZERO)
			elif hdiff == 1 and _Tile.info.tile.type == 1: # regular to half tile
				on_connect_points(astar, movement_types, Tile, _Tile, Vector2i(3, 0))
			elif hdiff == 0: # movement between regular tiles
				on_connect_points(astar, movement_types, Tile, _Tile, Vector2i.ZERO)
			elif hdiff < 0: # jump down from regular tile
				if hdiff == -1:
					on_connect_points(astar, movement_types, Tile, _Tile, Vector2i(3, 0))
				else: on_connect_points(astar, movement_types, Tile, _Tile, Vector2i(4, hdiff))
	tiles_by_adjacent.erase(Unit.Tile)
	
	for Tile in tiles_by_adjacent.keys(): # disconnect all points that a unit can't get to
		var id_path_tiles: Array = Array(astar.get_id_path(Unit.Tile.get_instance_id(), Tile.get_instance_id()))\
		.map(func(x: int): return instance_from_id(x))
		var size: int = id_path_tiles.size()
		
		for i in range(size):
			if i > 0 and i == size - 1:
				var EnemyUnit: UnitGD = Units.unit_by_tile(id_path_tiles[i])
				if EnemyUnit != null:
					var id: int = id_path_tiles[i].get_instance_id()
					for point in astar.get_point_connections(id):
						if point != id_path_tiles[i - 1].get_instance_id():
							astar.disconnect_points(id, point)
				
	for Tile in tiles_by_adjacent.keys():
		var path: Dictionary = on_create_true_path(Array(astar.get_id_path(Unit.Tile.get_instance_id(), Tile.get_instance_id()))\
		.map(func(x: int): return instance_from_id(x)), movement_types) # Creates paths of [[Tile, vec2(id)], [Tile, vec2(id)]]
		
		if path.size > 0 and path.size <= Unit.speed + int(path.types[path.size - 1].x == 1):
			movement_paths[Tile] = path
			movement_paths.tiles.append(Tile)

func on_create_true_path(id_path: Array, movement_types: Array) -> Dictionary:
	var true_path: Dictionary = {"tiles": [], "types": [], "size": 0}
	for i in range(id_path.size()):
		if i > 0:
			for tile_array in movement_types:
				if tile_array[0] == id_path[i - 1] and tile_array[1] == id_path[i]:
					true_path.tiles.append(tile_array[1])
					true_path.types.append(tile_array[2])
	
	true_path.size = true_path.tiles.size()
	return true_path
	
# 0 = MoveTile, 1 = AttackTile, 2 = ClimbInstant, 3 = Jump, 4 = Drop
func on_connect_points(astar: AStar3D, movement_types: Array, Tile: TileGD, _Tile: TileGD, type: Vector2) -> void:
	movement_types.append([Tile, _Tile, type])
	astar.connect_points(Tile.get_instance_id(), _Tile.get_instance_id(), false)
	
func on_tile_hovered(Tile: TileGD, type: String) -> void:
	if "RegularInspected" not in Tile.tile_state or "SpawnInspected" not in Tile.tile_state:
		on_set_tile_material(Tile, type + "Inspected")
		
	if Units.PlayerManager.UnitSelected != null and "UnitSelected" not in Tile.tile_state and movement_paths.has(Tile): # create hovered tiles
		path_hovered_info = movement_paths[Tile]
		for i in range(path_hovered_info.tiles.size()):
			on_set_tile_material(path_hovered_info.tiles[i], "PathHovered")
			if path_hovered_info.types[i].x == 1:
				on_set_tile_material(path_hovered_info.tiles[i], "EnemyInRange")

func on_tile_unhovered(Tile: TileGD, type: String) -> void:
	if "RegularInspected" in Tile.tile_state or "SpawnInspected" in Tile.tile_state:
		on_remove_tile_material(Tile, type + "Inspected")
		
	if Units.PlayerManager.UnitSelected != null and "UnitSelected" not in Tile.tile_state:
		for _Tile in tiles_by_tile_state("PathHovered"):
			on_remove_tile_material(_Tile, "PathHovered")

var path_hovered_info: Dictionary
func on_path_hovered_tile_selected(Tile: TileGD) -> void:
	Units.PlayerManager.on_select_active_unit(Units.PlayerManager.UnitSelected)
	for i in range(path_hovered_info.tiles.size()):
		if path_hovered_info.types[i].x != 1:
			Units.move_to_tile(Units.PlayerManager.UnitSelected, path_hovered_info.tiles[i], path_hovered_info.types[i])
		else: Units.attack_enemy_or_target(Units.PlayerManager.UnitSelected, path_hovered_info.tiles[i])
		if Tile == path_hovered_info.tiles[i]: break
		
	on_remove_tile_material(Units.PlayerManager.UnitSelected.Tile, "SpectatingUnit")
	on_remove_tile_material(Units.PlayerManager.UnitSelected.Tile, "TurnActive")
	Units.PlayerManager._on_unit_deselected(Units.PlayerManager.UnitSelected, true)
		
func on_enemy_found_tile_selected(Tile: TileGD, Unit: UnitGD) -> void:
	Units.attack_enemy_or_target(Unit, Tile)
	
var MATERIAL_NAME_TO_MATERIAL: Dictionary = {
	"RegularInspected": null, # When hovering over a regular tile
	"SpawnInspected": null, # Over a spawn tile
	"UnitSelected": null, # Clicked on a unit
	"PathHovered": null, # When seeing where you should go
	"MovementRange": null, # Possible movement positions
	"EnemyInRange": null, # Enemies you can click on and attack
	"UnitInspected": null, # When inspected with the unit status
	
	"SpectatingUnit": null, # Allies who's turn it's not but they are being spectated
	"TurnActive": null, # Allies that it's currently the unit turn of
	"TurnUsed": null, # Allies that used up their unit turn
	"EnemyOccupy": null, # Tiles where an enemy exists
	
	"": null,
}
 
var MATERIAL_PRIORITIES: Array = ["", "MovementRange", "RegularInspected",
 "SpawnInspected", "PathHovered"] + Helper.unit_states + ["UnitSelected", "UnitInspected", "EnemyInRange"]

var base_material: Material = preload("res://assets/materials/base_materials/base_material.tres")
func on_set_default_shader_parameters() -> void:
	for key in MATERIAL_NAME_TO_MATERIAL.keys():
		if key not in ["", "reset"]: 
			MATERIAL_NAME_TO_MATERIAL[key] = base_material.duplicate()
			MATERIAL_NAME_TO_MATERIAL[key].material_name = key
	
	MATERIAL_NAME_TO_MATERIAL["RegularInspected"].albedo_color = Color(0.5, 0.5, 0.5)
	MATERIAL_NAME_TO_MATERIAL["SpawnInspected"].albedo_color = Color(0, 1, 0)
	MATERIAL_NAME_TO_MATERIAL["MovementRange"].albedo_color = Color(1, 1, 0)
	MATERIAL_NAME_TO_MATERIAL["UnitSelected"].albedo_color = Color(0, 1, 1)
	MATERIAL_NAME_TO_MATERIAL["PathHovered"].albedo_color = Color(1, 0, 1)
	MATERIAL_NAME_TO_MATERIAL["EnemyInRange"].albedo_color = Color(1, 0.7, 0.7)
	MATERIAL_NAME_TO_MATERIAL["UnitInspected"].albedo_color = Color(0.8, 0.8, 0.8)
	
	MATERIAL_NAME_TO_MATERIAL["SpectatingUnit"].albedo_color = Color(0, 0, 1)
	MATERIAL_NAME_TO_MATERIAL["TurnActive"].albedo_color = Color(0, 0, 0)
	MATERIAL_NAME_TO_MATERIAL["TurnUsed"].albedo_color = Color(0.35, 0.35, 0.35)
	MATERIAL_NAME_TO_MATERIAL["EnemyOccupy"].albedo_color = Color(1, 0, 0)
	
	
func on_remove_tile_material(Tile: TileGD, material_name: String = "UnitNull") -> void:
	if material_name == "":
		Tile.tile_state = []
	elif material_name == "UnitNull":
		Tile.tile_state = Tile.tile_state.filter(func(x: String): return x in Helper.unit_states)
	else: 
		Tile.tile_state.erase(material_name)
	on_set_tile_highest_material(Tile)
	
func on_set_tile_material(Tile: TileGD, material_name: String):
	if !Tile.tile_state.has(material_name):
		if material_name not in Helper.unit_states:
			Tile.tile_state.append(material_name)
		else:
			Tile.tile_state = Tile.tile_state.filter(func(x: String): return x not in Helper.unit_states)
			Tile.tile_state.append(material_name)
	
	on_set_tile_highest_material(Tile)

func on_set_tile_highest_material(Tile: TileGD) -> void:
	var highest: int = 0
	for tile_state in Tile.tile_state:
		var f: int = MATERIAL_PRIORITIES.find(tile_state)
		if f > highest: highest = f
	
	Tile.tile.set_material(MATERIAL_NAME_TO_MATERIAL[MATERIAL_PRIORITIES[highest]])

func on_lock_inputs_changed(x: bool) -> void:
	if !x and !LevelUI.is_mouse_in_ui:
		on_force_mouse_entered()
		
func on_mouse_enters_ui(x: bool) -> void:
	if active_tile and x: on_tile_mouse_exited(active_tile, true)
	elif active_tile == null and !x:
		on_force_mouse_entered()

func on_force_mouse_entered() -> void:
	if active_tile != null: on_tile_mouse_exited(active_tile, true)
	var new_tile: TileGD = on_find_tile_by_raycast()
	if new_tile != null: on_tile_mouse_entered(new_tile, true)

const RAY_LENGTH: int = 1000
func on_find_tile_by_raycast() -> TileGD:
	var to: Vector3 = SpectateCamera.project_ray_normal(get_viewport().get_mouse_position()) * RAY_LENGTH
	var ray: RayCast3D = Vision.TileRayCast
	
	ray.position = SpectateCamera.position
	ray.target_position = to
	ray.force_raycast_update()
	
	var node: Node3D = ray.get_collider()
	if node: node = node.get_parent()
	return node
