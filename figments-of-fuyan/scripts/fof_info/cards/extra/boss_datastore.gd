class_name BossDatastore extends Resource

@export var phase: int
@export var boss_intent_used_this_turn: bool
@export var boss_intent_name: String
@export var boss_intent_name_to_cooldown: Dictionary = {}

@export var condition_results: Dictionary # name : BossIntentConditionResult
@export var boss_tile_intents: BossTileIntents

@export var intent_duration: int

#region Default
func _init(_phase: int = 0, _boss_intent_name: String = "", _boss_intent_name_to_cooldown: Dictionary = {}) -> void:
	phase = _phase
	boss_intent_name = _boss_intent_name
	boss_intent_name_to_cooldown = _boss_intent_name_to_cooldown
	boss_tile_intents = BossTileIntents.new()
	
func onSave() -> void:
	boss_tile_intents.onSave()
	for condition: BossIntentConditionResult in condition_results.values():
		condition.onSave()

func onLoad() -> void:
	boss_tile_intents.onLoad()
	for condition: BossIntentConditionResult in condition_results.values():
		condition.onLoad()
#endregion
		
#region Tile Intents
func onUpdateTileIntents(action: OccupyAction = null) -> void:
	if action.Tile == null: return # If it means death
	if action.PreviousTile == null: return # If it means awaken
	
	var valid_tile_intents: Array = getTileIntents().filter(func(x: TileIntentDatastore): return !x.isStaticTile() and action.PreviousTile.getCoords() == x.coords)
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
		
func onUpdateTileIntentsRotation(action: ChangeTileRotationAction) -> void:
	if action.GameObject is not CardGD: return
	var valid_tile_intents: Array = getTileIntents().filter(func(x: TileIntentDatastore):\
		return !x.isStaticTile() and x.offset_datastore.tile_rotation != -1 and action.GameObject.coords == x.coords)
		
	for datastore: TileIntentDatastore in valid_tile_intents:
		var PreviousTile: TileGD = datastore.getTile()
		if PreviousTile != null:
			PreviousTile.setTileIntent(Game.TileIntents.NULL)
			
	for datastore: TileIntentDatastore in valid_tile_intents:
		datastore.setTileRotation(action.tile_rotation)
		
		var Tile: TileGD = datastore.getTile()
		if Tile == null:
			continue
			
		Tile.setTileIntent(datastore.intent_type)
	
func onFirstUpdateTileIntents(_tile_intents: Array[TileIntentDatastore], old_tile_intents: Array[TileIntentDatastore] = getTileIntents()) -> void:
	onClearTileIntents(old_tile_intents)
	setTileIntents(_tile_intents)
	
	for datastore: TileIntentDatastore in getTileIntents():
		var Tile: TileGD = datastore.getTile()
		if Tile == null: continue
		
		Tile.setTileIntent(datastore.intent_type)
	
func onClearTileIntents(old_tile_intents: Array = getTileIntents()) -> void:
	for datastore: TileIntentDatastore in old_tile_intents:
		var Tile: TileGD = datastore.getTile()
		if Tile == null: continue
		Tile.setTileIntent(Game.TileIntents.NULL)
	boss_tile_intents.onClear()
	
func getTileIntents() -> Array[TileIntentDatastore]:
	return boss_tile_intents.getTileIntents()
	
func setTileIntents(tile_intents: Array[TileIntentDatastore]) -> void:
	boss_tile_intents.setTileIntents(tile_intents)
#endregion
	
#region Tile Results
func getTileResults() -> Dictionary[TileGD, String]:
	return boss_tile_intents.getTileResults()
#endregion

#region Condition Results
func onResetConditionResults() -> void:
	condition_results = {}
	
func setConditionResult(condition_result: BossIntentConditionResult, name: String) -> void:
	condition_results[name] = condition_result
	
func getConditionResult(name: String) -> BossIntentConditionResult:
	return condition_results[name]
#endregion

#region Boss Tile Intents
func setBossTileIntents(_boss_tile_intents: BossTileIntents) -> void:
	boss_tile_intents = _boss_tile_intents
#endregion

#region Intent Duration
func setIntentDuration(_intent_duration: int) -> void:
	intent_duration = _intent_duration
	
func getIntentDuration() -> int:
	return intent_duration
#endregion
