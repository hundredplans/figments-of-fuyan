class_name VisionGD
extends Node3D

@onready var TileRayCast: RayCast3D = $TileRayCast
@onready var MouseRayCast: RayCast3D = $MouseRayCast

var LevelUI: LevelUIGD
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
	LevelUI.on_update_vision()

func on_find_visible_tiles() -> Array:
	var _visible_tiles: Dictionary = {}
	on_merge_visible_tiles(_visible_tiles, Tiles.on_is_type_get_tiles("Spawn", "obj"))
	
	var units: Array = Units.on_units()
	var all_units: Array = Units.all_units()
	for Unit in units:
		Unit.units_in_vision = []
		TileRayCast.position = Unit.global_position
		TileRayCast.position.y += Unit.height.eye + (0.6 if Unit.Tile.info.tile.type > 0 else 0.0)
		var found_tiles: Array = onCircleRay(TileRayCast, tiles_in_vision(Unit))
		for _Unit in all_units:
			if _Unit.Tile in found_tiles:
				Unit.units_in_vision.append(_Unit)
		on_merge_visible_tiles(_visible_tiles, found_tiles)
	on_merge_visible_tiles(_visible_tiles, units.map(func(x: UnitGD): return x.Tile))
	return _visible_tiles.keys()

const RAY_COUNT: int = 100
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
					collisions.append(Tile)
	return collisions
func tiles_in_vision(Unit: UnitGD) -> Array:
	return Tiles.all_in_range(Unit.Tile, VISION_RANGE, false, true).filter(func(x: TileGD): return x.info.tile.id > 0 or x.info.wall.id > 0	)

func on_merge_visible_tiles(_visible_tiles: Dictionary, tiles: Array) -> void:
	for tile in tiles: _visible_tiles.merge({tile: null})
	
var GreyscaleMaterial: Material = preload("res://scenes/screens/level_map/utility_nodes/vision/black_material.tres")
func on_apply_visibility(other_tiles: Array) -> void:
	for Tile in visible_tiles:
		for type in ["TileDecoration", "WallDecoration", "Object"]:
			for child in Tile.get_node(type).get_children():
				for grandchild in child.get_children():
					if grandchild is MeshInstance3D:
						grandchild.visible = true
		
		for btab in [0, 2]:
			Tile.set_material(null, btab)
		Tile.greyscale = false
		
	for Tile in other_tiles:
		for type in ["TileDecoration", "WallDecoration", "Object"]:
			for child in Tile.get_node(type).get_children():
				for grandchild in child.get_children():
					if grandchild is MeshInstance3D:
						grandchild.visible = false
		
		Tiles.on_remove_tile_material(Tile, "")
		Tile.greyscale = true
		
		for btab in [0, 2]:
			Tile.set_material(GreyscaleMaterial, btab)
	
	for Unit in Units.on_units(1, "Ally"):
		Unit.visible = Unit.Tile in visible_tiles

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
