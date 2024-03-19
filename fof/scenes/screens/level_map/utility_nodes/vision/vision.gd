class_name VisionGD
extends Node3D

@onready var TileRayCast: RayCast3D = $TileRayCast
@onready var MouseRayCast: RayCast3D = $MouseRayCast

var SpectateCamera: Node3D
var LevelUI: LevelUIGD
var Units: UnitsGD
var Tiles: TilesGD
var GameState: Node
const VISION_RANGE: int = 5

var visible_tiles: Array

func on_recalculate_vision() -> void:
	var other_tiles: Array = []
	var old_visible_tiles: Array = visible_tiles.duplicate()
	visible_tiles = []
	match vision_mode:
		0:
			visible_tiles = on_find_visible_tiles()
		1:
			var _visible_tiles: Dictionary = {}
			if ActiveUnitVision != null:
				on_merge_visible_tiles(_visible_tiles, onUnitRayCast(ActiveUnitVision))
				visible_tiles = _visible_tiles.keys()
		2: pass
		
	other_tiles = Tiles.tiles_unique(Tiles.get_children(), visible_tiles)
	on_find_units_enter_vision(old_visible_tiles)
	on_apply_visibility(other_tiles)
	LevelUI.on_update_vision()

func onUnitRayCast(Unit: UnitGD, all_units: Array = Units.all_units()) -> Array:
	Unit.units_in_vision = []
	TileRayCast.position = Unit.global_position
	TileRayCast.position.y += Unit.height.eye + (0.6 if Unit.Tile.info.tile.type > 0 else 0.0)
	
	var found_tiles: Array = onCircleRay(TileRayCast, tiles_in_vision(Unit))
	for i in range(found_tiles.size()):
		found_tiles += found_tiles[i].top_of_cliff_wall
		
	for _Unit in all_units:
		if _Unit.Tile in found_tiles and _Unit != Unit:
			Unit.units_in_vision.append(_Unit)
	return found_tiles

func on_find_visible_tiles() -> Array:
	var _visible_tiles: Dictionary = {}
	on_merge_visible_tiles(_visible_tiles, Tiles.on_is_type_get_tiles("Spawn", "obj"))
	var units: Array = Units.on_units()
	var all_units: Array = Units.all_units()
	
	for Unit in units:
		on_merge_visible_tiles(_visible_tiles, onUnitRayCast(Unit, all_units))
		
	on_merge_visible_tiles(_visible_tiles, units.map(func(x: UnitGD): return x.Tile))
	on_merge_visible_tiles(_visible_tiles, onUnitsHeightAdjacentTiles(units))
	return _visible_tiles.keys()

func onUnitsHeightAdjacentTiles(units: Array) -> Array:
	var found_tiles: Array = []
	for Unit in units:
		if Unit.Tile.info.position.w > 0:
			for direction in Tiles.cube_directions:
				var pos: Vector3 = Vector3(Unit.Tile.info.position.x, Unit.Tile.info.position.y, Unit.Tile.info.position.z) + direction
				for w in range(Unit.Tile.info.position.w - 1, -1, -1):
					var Tile: TileGD = Tiles.position_to_tile(Vector4(pos.x, pos.y, pos.z, w))
					if Tile != null and Tile.info.tile.id > 0:
						found_tiles.append(Tile)
						break
				
	for i in range(found_tiles.size()):
		found_tiles += found_tiles[i].top_of_cliff_wall
	return found_tiles
	
const RAY_COUNT: int = 75
func onCircleRay(Ray: RayCast3D, vision_range: Array) -> Array:
	var collisions: Array = []
	for i in range(RAY_COUNT):
		var phi: float = (i * (PI * 2)) / RAY_COUNT
		var theta: float = 0
		for j in range(RAY_COUNT):
			theta = (j * PI) / RAY_COUNT
			Ray.target_position = Vector3(sin(theta) * cos(phi), sin(theta) * sin(phi), cos(theta)) * 100
			Ray.force_raycast_update()
			if Ray.is_colliding():
				var Tile: TileGD = Ray.get_collider().get_node("../../..")
				if Tile in vision_range:
					vision_range.erase(Tile)
					var type: String = Ray.get_collider().get_node("../..").type
					if Tile.info[type].multi_tile.size() > 0:
						if Tile.solid_status == 1:
							for _Tile in Tile.info[type].multi_tile:
								collisions.append(_Tile)
					else: collisions.append(Tile)
					
	return collisions
func tiles_in_vision(Unit: UnitGD) -> Array:
	return Tiles.all_in_range(Unit.Tile, VISION_RANGE, true, true).filter(func(x: TileGD): return x.info.tile.id > 0 or x.info.wall.id > 0	)

func on_merge_visible_tiles(_visible_tiles: Dictionary, tiles: Array) -> void:
	for tile in tiles: _visible_tiles.merge({tile: null})
	
func on_apply_visibility(other_tiles: Array) -> void:
	for Tile in visible_tiles: Tiles.on_remove_tile_material(Tile, "Greyscale")
	for Tile in other_tiles: Tiles.on_set_tile_material(Tile, "Greyscale")
	for Unit in Units.on_units(0, "Enemy"): Unit.visible = Unit.Tile in visible_tiles

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

func is_unit_in_unit_vision(VisionUnit: UnitGD, ObservedUnit: UnitGD, include_self: bool) -> bool:
	if VisionUnit != null and ObservedUnit != null:
		if VisionUnit == ObservedUnit: return include_self
		return ObservedUnit in VisionUnit.units_in_vision

	return false

var vision_mode: int = 0 # 0 = default, 1 = unit_vision, 2 
func on_vision_mode_set(x: int) -> void:
	ActiveUnitVision = null
	vision_mode = x
	on_recalculate_vision()

var ActiveUnitVision: UnitGD
func on_tile_hovered(Tile: TileGD) -> void:
	if vision_mode == 1 and ActiveUnitVision == null:
		var Unit: UnitGD = Units.unit_by_tile(Tile)
		if Unit != null:
			ActiveUnitVision = Unit
			on_recalculate_vision()
		
func on_tile_unhovered(__: TileGD) -> void:
	if vision_mode == 1 and ActiveUnitVision != null:
		var keep_unit: UnitGD = ActiveUnitVision
		ActiveUnitVision = null
		await get_tree().create_timer(0.02).timeout
		
		if Tiles.active_tile != null and !("MovementRange" in Tiles.active_tile.tile_state):
			on_recalculate_vision()
		else: ActiveUnitVision = keep_unit

func on_player_end_turn_phase_start() -> void:
	on_vision_mode_set(0)
