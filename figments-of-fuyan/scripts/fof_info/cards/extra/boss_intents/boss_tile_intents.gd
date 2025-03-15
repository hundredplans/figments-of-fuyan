class_name BossTileIntents extends Resource

@export var tile_intents: Array[TileIntentDatastore] = []

var tile_results: Dictionary[TileGD, String] = {}
@export var tile_results_public_ids: Dictionary[int, String] = {}

func _init(_tile_intents: Array[TileIntentDatastore] = [], _tile_results: Dictionary[TileGD, String] = {}) -> void:
	tile_intents = _tile_intents
	tile_results = _tile_results

func setTileIntents(_tile_intents: Array[TileIntentDatastore]) -> void:
	tile_intents = _tile_intents

func getTileIntents() -> Array[TileIntentDatastore]:
	return tile_intents

func onSave() -> void:
	tile_results_public_ids = {}
	for Tile: TileGD in tile_results:
		tile_results_public_ids[Tile.public_id] = tile_results[Tile]
	
func onLoad() -> void:
	tile_results = {}
	for public_id: int in tile_results_public_ids:
		var Tile: TileGD = Game.onFindPublicIDObject(public_id)
		tile_results[Tile] = tile_results_public_ids[public_id]

func onClear() -> void:
	tile_intents = []
	
func setTileResults(_tile_results: Dictionary[TileGD, String]) -> void:
	tile_results = _tile_results
	
func getTileResults() -> Dictionary[TileGD, String]:
	return tile_results
