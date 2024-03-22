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

var spawn_vision: Array

func on_recalculate_vision(Unit: UnitGD = null) -> void:
	var visible_tiles: Array = [[], []]
	var all_units: Array = Units.all_units()
	var ally_units: Array = Units.on_units()
	match vision_mode:
		0:
			if Unit != null:
				var old_vision: Array = Unit.visible_tiles.duplicate()
				Unit.onCircleRay()
				for _Unit in all_units:
					var was_visible: bool = _Unit in Unit.visible_units
					var is_visible: bool = _Unit in Unit.visible_tiles
					if was_visible and !is_visible:
						if _Unit.visible_units.size() == 1:
							Units.on_unit_exits_vision(_Unit)
							Unit.visible_units.erase(_Unit)
							_Unit.visible_units.erase(Unit)
							
					elif !was_visible and is_visible:
						if _Unit.visible_units.is_empty():
							Units.on_unit_enters_vision(_Unit)
							Unit.visible_units.append(_Unit)
							_Unit.visible_units.append(Unit)
							
			for Tile in get_children():
				visible_tiles[int(ally_units.any(func(x: UnitGD): return x.visible_tiles.any(func(x: TileGD): return Tile == x)))].append(Tile)
		1:
			if ActiveUnitVision == null:
				visible_tiles = [[], Tiles.get_children()]
			else:
				for Tile in Tiles.get_children():
					visible_tiles[int(Tile in ActiveUnitVision.visible_tiles)].append(Tile)
		2:
			visible_tiles = spawn_vision
		3: # enemy vision
			pass
	
	on_apply_visibility(visible_tiles)
	LevelUI.on_update_vision()
	
	#var unit_visions: Array = ally_units.map(func(x: ))
	
	#var other_tiles: Array = []
	#var old_visible_tiles: Array = visible_tiles.duplicate()
	#visible_tiles = []
	#match vision_mode:
		#0:
			#visible_tiles = on_find_visible_tiles(Unit)
		#1:
			#var _visible_tiles: Dictionary = {}
			#if ActiveUnitVision != null:
				#on_merge_visible_tiles(_visible_tiles, onUnitRayCast(ActiveUnitVision))
				#visible_tiles = _visible_tiles.keys()
		#2: 
			#var _visible_tiles: Dictionary = {}
			#on_merge_visible_tiles(_visible_tiles, Tiles.get_children().filter(func(x: TileGD): return x.obj.id == 2))
			#visible_tiles = _visible_tiles.keys()
		#
	#other_tiles = Tiles.tiles_unique(Tiles.get_children(), visible_tiles)
	#on_find_units_enter_vision(old_visible_tiles)
	#on_apply_visibility(other_tiles)
	#LevelUI.on_update_vision()

func on_start_phase_start() -> void:
	spawn_vision = [[], []]
	for Tile in Tiles.get_children():
		spawn_vision[int(Tile.obj.id != 2)].append(Tile)

func on_find_visible_tiles(_Unit: UnitGD) -> Array:
	var _visible_tiles: Dictionary = {}
	on_merge_visible_tiles(_visible_tiles, Tiles.on_is_type_get_tiles("Spawn", "obj"))
	var units: Array = Units.on_units()
	var all_units: Array = Units.all_units()
	
	#if _Unit != null:
		#vision_by_unit.Unit = onUnitRayCast(_Unit, all_units)
		#on_merge_visible_tiles(_visible_tiles, vision_by_unit.Unit)
		#
		#for Unit in units:
			#if Unit != _Unit and Unit != null:
				#on_merge_visible_tiles(_visible_tiles, vision_by_unit.Unit)
	#else:
		#for Unit in units:
			#vision_by_unit.Unit = onUnitRayCast(Unit, all_units)
			#on_merge_visible_tiles(_visible_tiles, vision_by_unit.Unit)
		
	on_merge_visible_tiles(_visible_tiles, units.map(func(x: UnitGD): return x.Tile))
	return _visible_tiles.keys()
	
func tiles_in_vision(Unit: UnitGD) -> Array:
	return Tiles.all_in_range(Unit.Tile, VISION_RANGE, true, true).filter(func(x: TileGD): return x.tile.id > 0 or x.wall.id > 0	)

func on_merge_visible_tiles(_visible_tiles: Dictionary, tiles: Array) -> void:
	for tile in tiles: _visible_tiles.merge({tile: null})
	
func on_apply_visibility(tiles: Array) -> void:
	for Tile in tiles[0]: Tiles.on_remove_tile_material(Tile, "Greyscale")
	for Tile in tiles[1]: Tiles.on_set_tile_material(Tile, "Greyscale")
	#for Unit in Units.on_units(0, "Enemy"): Unit.visible = Unit.Tile in visible_tiles

func on_find_units_enter_vision(old_visible_tiles: Array) -> void:
	pass
	#for Unit in Units.all_units():
		#var is_in_old_vision: bool = old_visible_tiles.any(func(x: TileGD): return x == Unit.Tile)
			#var is_in_vision: bool = visible_tiles.any(func(x: TileGD): return x == Unit.Tile)
		#
		#if !(is_in_old_vision and is_in_vision):
			#if is_in_vision: Units.on_unit_enters_vision(Unit)
			#elif is_in_old_vision: Units.on_unit_exits_vision(Unit)

func is_unit_in_vision(Unit: UnitGD) -> bool: # two diff visions for the two teams
	return Units.on_units(Unit.team, "Enemy").any(func(x: UnitGD): return Unit in x.visible_units)

func is_unit_in_unit_vision(VisionUnit: UnitGD, ObservedUnit: UnitGD, include_self: bool) -> bool:
	if VisionUnit != null and ObservedUnit != null:
		if VisionUnit == ObservedUnit: return include_self
		return ObservedUnit in VisionUnit.units_in_vision

	return false

var vision_mode: int = 0 # 0 = default, 1 = unit_vision, 2 = spawn_vision
func on_vision_mode_set(x: int) -> void:
	if x != vision_mode:
		ActiveUnitVision = null
		vision_mode = x
		on_recalculate_vision()

var ActiveUnitVision: UnitGD
func on_tile_hovered(Tile: TileGD) -> void:
	if vision_mode == 1 and ActiveUnitVision == null:
		var Unit: UnitGD = Units.unit_by_tile(Tile)
		if Unit == null and Tile in Tiles.path_hovered_info.tiles:
			Unit = Units.PlayerManager.UnitSelected
		
		if Unit != null:
			ActiveUnitVision = Unit
			on_recalculate_vision()
		
func on_tile_unhovered(__: TileGD) -> void:
	if vision_mode == 1 and ActiveUnitVision != null:
		var keep_unit: UnitGD = ActiveUnitVision
		ActiveUnitVision = null
		
		await get_tree().create_timer(0.02).timeout
		
		if Tiles.active_tile == null or !("MovementRange" in Tiles.active_tile.tile_state):
			on_recalculate_vision()
		else: ActiveUnitVision = keep_unit

func on_player_end_turn_phase_start() -> void:
	on_vision_mode_set(0)
