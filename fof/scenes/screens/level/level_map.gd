extends Node3D
var GameState: Node

@onready var Tiles: Node3D = $Tiles
var _LevelTile: PackedScene = preload("res://scenes/screens/level/level_tile.tscn")
func on_load_default_world_state() -> void:
	for tile_info in GameState.level_info.tiles:
		on_create_tile(tile_info)
	
func on_load_world_history() -> void:
	pass
	
var TILE_OBJECT_NAMES: Array = ["tile", "wall", "obj", "tdeco", "wdeco"]
func on_create_tile(tile_info: Dictionary) -> void:
	if TILE_OBJECT_NAMES.any(func(x: String): return tile_info[x].id > 0):
		var LevelTile: Node3D = _LevelTile.instantiate()
		Tiles.add_child(LevelTile)
		tile_info.position = Vector4(tile_info.position[0], tile_info.position[1], tile_info.position[2], tile_info.position[3])
		LevelTile.position = Vector3(
		(sqrt(3) * tile_info.position.x + sqrt(3) * tile_info.position.y * 0.5),
		tile_info.position.w * 1.2,
		tile_info.position.y * 3 / 2)
		
		LevelTile.area = GameState.area_info.id
		LevelTile.tile_info = tile_info
		
		LevelTile.on_load_info("Tile")
		LevelTile.on_load_info("Wall")
		LevelTile.on_load_info("TDeco")
		LevelTile.on_load_info("WDeco")
