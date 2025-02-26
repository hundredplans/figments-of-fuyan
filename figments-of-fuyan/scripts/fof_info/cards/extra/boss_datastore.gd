class_name BossDatastore extends Resource

var boss_intent_tiles: Dictionary = {}
@export var phase: int
@export var boss_intent_used_this_turn: bool
@export var boss_intent_name: String
@export var boss_intent_name_to_cooldown: Dictionary = {}
@export var tile_intents: Array[TileIntentDatastore] = []
@export var boss_intent_tiles_public_ids: Dictionary = {}

func _init(_phase: int = 0, _boss_intent_name: String = "", _boss_intent_name_to_cooldown: Dictionary = {},\
_tile_intents: Array[TileIntentDatastore] = []) -> void:
	phase = _phase
	boss_intent_name = _boss_intent_name
	boss_intent_name_to_cooldown = _boss_intent_name_to_cooldown
	tile_intents = _tile_intents
	
func onSave() -> void:
	boss_intent_tiles_public_ids = {}
	for Tile: TileGD in boss_intent_tiles:
		boss_intent_tiles_public_ids[Tile.public_id] = boss_intent_tiles[Tile]

func onLoad() -> void:
	boss_intent_tiles = {}
	for public_id: int in boss_intent_tiles_public_ids:
		boss_intent_tiles[Game.onFindPublicIDObject(public_id)] = boss_intent_tiles_public_ids[public_id]
		
func onUpdateTileIntents(action: OccupyAction = null) -> void:
	if action.Tile == null: return # If it means death
	
	var valid_tile_intents: Array = tile_intents.filter(func(x: TileIntentDatastore): return !x.isStaticTile() and action.PreviousTile.getCoords() == x.coords)
	for datastore: TileIntentDatastore in valid_tile_intents:
		var PreviousTile: TileGD = datastore.getTile()
		if PreviousTile != null:
			PreviousTile.setTileIntent(Game.TileIntents.NULL)
		
	for datastore: TileIntentDatastore in valid_tile_intents:
		datastore.coords = action.Tile.getCoords()
		
		var Tile: TileGD = datastore.getTile()
		if Tile == null:
			continue
		
		Tile.setTileIntent(datastore.intent_type)
		
func setTileIntents(_tile_intents: Array[TileIntentDatastore]) -> void:
	onClearTileIntents()
	tile_intents = _tile_intents
	
	for datastore: TileIntentDatastore in tile_intents:
		var Tile: TileGD = datastore.getTile()
		if Tile == null: continue
		
		Tile.setTileIntent(datastore.intent_type)
		
	
func onClearTileIntents() -> void:
	for datastore: TileIntentDatastore in tile_intents:
		var Tile: TileGD = datastore.getTile()
		if Tile == null: continue
		Tile.setTileIntent(Game.TileIntents.NULL)
	tile_intents = []
	
func setBossIntentTiles(_boss_intent_tiles: Dictionary = {}) -> void:
	boss_intent_tiles = _boss_intent_tiles

func getBossIntentTiles() -> Array:
	return boss_intent_tiles.keys()
