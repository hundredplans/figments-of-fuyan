class_name UniqueTilesGD
extends Node

var all_tiles: Array = []
func _ready() -> void:
	const DIR_PATH: String = "res://assets/base_game/unique_tiles/infos"
	all_tiles = Array(DirAccess.get_files_at(DIR_PATH)).map(func(x: String): return load(DIR_PATH + x))

func onAddUniqueTile(Tile: TileGD) -> void:
	var tile_info: UniqueTileInfoGD = onFindTileInfo(Tile.tile.id)
	var unique_tile := Node.new()
	unique_tile.script = tile_info.tile_script
	unique_tile.setInfo(Tile)
	add_child(unique_tile)
	
	if unique_tile.has_method("onReady"): unique_tile.onReady()

func onTrigger(Unit: UnitGD, trigger: int, args: TriggerInfoGD) -> void:
	for unique_tile in get_children().filter(func(x: ToolGD): return x.has_method("onTrigger")):
		unique_tile.onTrigger(Unit, trigger, args)

func onFindTileInfo(id: int) -> UniqueTileInfoGD:
	return all_tiles.filter(func(x: UniqueTileInfoGD): return x.id == id)[0]
