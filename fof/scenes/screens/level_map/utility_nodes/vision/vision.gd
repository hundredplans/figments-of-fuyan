class_name VisionGD
extends Node3D

var Units: UnitsGD
var Tiles: TilesGD
var GameState: Node
const VISION_RANGE: int = 5

func on_recalculate_vision() -> void:
	on_clear_darkness()
	var visible_tiles: Array = on_find_visible_tiles()
	var other_tiles: Array = Tiles.tiles_unique(Tiles.get_children(), visible_tiles)
	on_apply_visibility(visible_tiles, other_tiles)
	on_create_darkness(visible_tiles, other_tiles)
	
func on_clear_darkness() -> void:
	for child in get_children(): child.queue_free()

func on_find_visible_tiles() -> Array:
	var visible_tiles: Dictionary = {}
	on_merge_visible_tiles(visible_tiles, Tiles.on_is_type_get_tiles("Spawn", "obj"))
	
	for Unit in Units.on_units():
		on_merge_visible_tiles(visible_tiles, tiles_in_vision(Unit))
	return Tiles.positions_to_tiles(visible_tiles.keys())

func tiles_in_vision(Unit: UnitGD) -> Array:
	return Tiles.all_in_range(Unit.Tile, VISION_RANGE, true)

func on_merge_visible_tiles(visible_tiles: Dictionary, tiles: Array) -> void:
	for tile in tiles: visible_tiles.merge({tile.info.position: null})
	
func on_apply_visibility(visible_tiles: Array, other_tiles: Array) -> void:
	for tile in visible_tiles: tile.visible = true
	for tile in other_tiles: tile.visible = false
	
	for unit in Units.on_units(1, "Ally"):
		unit.visible = unit.Tile in visible_tiles

func on_create_darkness(visible_tiles: Array, other_tiles: Array) -> void:
	for Tile in other_tiles:
		var Darkness: MeshInstance3D = preload("res://scenes/screens/level_map/utility_nodes/vision/darkness.tscn").instantiate()
		Darkness.mesh = load("res://scenes/screens/level_map/utility_nodes/vision/darkness" \
		+ str(Tiles.nonexistent_positions_above(Tile).size()) + ".tres")
		
		Darkness.position = Tile.position
		Darkness.position.y = (Darkness.mesh.height / 2) + 0.3
		add_child(Darkness)
