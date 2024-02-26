class_name VisionGD
extends Node3D

@onready var TileRayCast: RayCast3D = $TileRayCast
@onready var DarknessNode: Node3D = $DarknessNode
var Units: UnitsGD
var Tiles: TilesGD
var GameState: Node
const VISION_RANGE: int = 5

var visible_tiles: Array

func on_start_phase_start() -> void:
	for Unit in Units.on_units(1):
		Units.on_unit_enters_vision(Unit)

func on_recalculate_vision() -> void:
	pass
	#on_clear_darkness()
	#var old_visible_tiles: Array = visible_tiles.duplicate()
	#visible_tiles = on_find_visible_tiles()
	#on_find_units_enter_vision(old_visible_tiles)
	#
	#var other_tiles: Array = Tiles.tiles_unique(Tiles.get_children_by_elevation(), visible_tiles)
	#on_apply_visibility(other_tiles)
	#on_create_darkness(other_tiles)
	
func on_clear_darkness() -> void:
	for child in DarknessNode.get_children(): child.queue_free()

func on_find_visible_tiles() -> Array:
	var _visible_tiles: Dictionary = {}
	on_merge_visible_tiles(_visible_tiles, Tiles.on_is_type_get_tiles("Spawn", "obj"))
	
	for Unit in Units.on_units():
		on_merge_visible_tiles(_visible_tiles, tiles_in_vision(Unit))
	return Tiles.positions_to_tiles(_visible_tiles.keys())

func tiles_in_vision(Unit: UnitGD) -> Array:
	return Tiles.all_in_range(Unit.Tile, VISION_RANGE, true)

func on_merge_visible_tiles(_visible_tiles: Dictionary, tiles: Array) -> void:
	for tile in tiles: _visible_tiles.merge({tile.info.position: null})
	
func on_apply_visibility(other_tiles: Array) -> void:
	for tile in visible_tiles: tile.visible = true
	for tile in other_tiles: tile.visible = false
	
	for unit in Units.on_units(1, "Ally"):
		unit.visible = unit.Tile in visible_tiles

func on_create_darkness(other_tiles: Array) -> void:
	for Tile in other_tiles:
		var Darkness: MeshInstance3D = preload("res://scenes/screens/level_map/utility_nodes/vision/darkness.tscn").instantiate()
		Darkness.mesh = load("res://scenes/screens/level_map/utility_nodes/vision/darkness" \
		+ str(Tiles.nonexistent_positions_above(Tile).size()) + ".tres")
		
		Darkness.position = Tile.position
		Darkness.position.y = (Darkness.mesh.height / 2) + 0.3
		DarknessNode.add_child(Darkness)

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
