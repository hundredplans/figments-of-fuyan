class_name VisionGD
extends Node3D

@onready var TileRayCast: RayCast3D = $TileRayCast
@onready var MouseRayCast: RayCast3D = $MouseRayCast
var Units: UnitsGD
var Tiles: TilesGD
var GameState: Node
const VISION_RANGE: int = 5

var visible_tiles: Array
var grey_tiles: Array

func on_recalculate_vision() -> void:
	var old_visible_tiles: Array = visible_tiles.duplicate()
	visible_tiles = on_find_visible_tiles()
	on_find_units_enter_vision(old_visible_tiles)
	
	var other_tiles: Array = Tiles.tiles_unique(Tiles.get_children(), visible_tiles)
	on_apply_visibility(other_tiles)
	on_create_darkness(other_tiles)

func on_find_visible_tiles() -> Array:
	var _visible_tiles: Dictionary = {}
	on_merge_visible_tiles(_visible_tiles, Tiles.on_is_type_get_tiles("Spawn", "obj"))
	
	var vision_check_passed: Array = []
	var units: Array = Units.on_units()
	for Unit in units:
		var vision_range: Array = tiles_in_vision(Unit)
		Unit.Tile.on_change_collision_state(false)
		TileRayCast.position = Unit.global_position
		TileRayCast.position.y += Unit.height.eye + (0.6 if Unit.Tile.info.tile.type > 0 else 0.0)
		
		for Tile in vision_range:
			TileRayCast.target_position = Tile.position - TileRayCast.position
			TileRayCast.target_position.y += (0.3 if Tile.info.tile.type == 0 else 0.6) if Tile.info.tile.id not in [3, 4] else 0.2
			TileRayCast.force_raycast_update()
			if TileRayCast.is_colliding():
				if TileRayCast.get_collider().get_node("../../..") == Tile:
					vision_check_passed.append(Tile)
		Unit.Tile.on_change_collision_state(true)
	
	on_merge_visible_tiles(_visible_tiles, vision_check_passed + units.map(func(x: UnitGD): return x.Tile))
	return Tiles.positions_to_tiles(_visible_tiles.keys())

func tiles_in_vision(Unit: UnitGD) -> Array:
	return Tiles.all_in_range(Unit.Tile, VISION_RANGE, false, true).filter(func(x: TileGD): return x.info.tile.id > 0)

func on_merge_visible_tiles(_visible_tiles: Dictionary, tiles: Array) -> void:
	for tile in tiles: _visible_tiles.merge({tile.info.position: null})
	
func on_apply_visibility(other_tiles: Array) -> void:
	for tile in visible_tiles: tile.visible = true
	for tile in other_tiles: tile.visible = false
	
	for unit in Units.on_units(1, "Ally"):
		unit.visible = unit.Tile in visible_tiles

func on_create_darkness(other_tiles: Array) -> void:
	for Tile in other_tiles:
		pass

func on_find_units_enter_vision(old_visible_tiles: Array) -> void:
	for Unit in Units.all_units():
		var is_in_old_vision: bool = old_visible_tiles.any(func(x: TileGD): return x == Unit.Tile)
		var is_in_vision: bool = visible_tiles.any(func(x: TileGD): return x == Unit.Tile)
		
		if !(is_in_old_vision and is_in_vision):
			if is_in_vision: Units.on_unit_enters_vision(Unit)
			elif is_in_old_vision: Units.on_unit_exits_vision(Unit)
			

func is_unit_in_vision(Unit: UnitGD) -> bool: # two diff visions for the two teams
	if Unit.team == 1: return Unit.Tile in visible_tiles
	return false
