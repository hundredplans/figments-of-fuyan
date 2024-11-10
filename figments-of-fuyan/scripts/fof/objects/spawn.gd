class_name SpawnGD
extends ObjectGD
var loaded_in_level: bool = false
var spawn_id: int

func onProcessAction(action: Action) -> void:
	if action.post:
		if action is OccupyAction and variation == 3 and spawn_id > 0 and action.Tile in occupied_tiles:
			onToolPickedUp(action)

func onLoadData(data: SavedData) -> void:
	super(data)
	spawn_id = data.spawn_id
	add_to_group("SpawnsGD")
	match variation:
		0: add_to_group("AllySpawnsGD")
		1: add_to_group("EnemySpawnsGD")
		2: add_to_group("NeutralSpawnsGD")
		3:
			if spawn_id == 0: return
			var tool_info: ToolInfo = Helper.getFofInfoID(ToolInfo, spawn_id)
			if tool_info.model != null:
				add_to_group("ToolSpawnsGD")
				add_child(tool_info.model.instantiate())

func onLoadDataLevelFofInit() -> void:
	super()
	if is_in_group("AllySpawnsGD"):
		onPushAction(RevealAction.new(self))
		
	if variation == 3: return
	
	var new_spawn_id: int = spawn_id if spawn_id > 0 else getNewSpawnId()
	if new_spawn_id == 0: return
	get_tree().get_nodes_in_group("AreasGD")[0].basic_card_ids.pick_random()
	var Tile: TileGD = getTile()
	var Card: CardGD = Game.getNewFieldCard(new_spawn_id, Tile, variation, tile_rotation, false)
	onPushAction(AwakenAction.new(Card, Tile))

func getNewSpawnId() -> int:
	if is_in_group("EnemySpawnsGD"):
		var spawns: Array = get_tree().get_nodes_in_group("EnemySpawnsGD").filter(func(x: SpawnGD): return x.spawn_id == 0)
		var index: int = spawns.find(self)
		return get_tree().get_nodes_in_group("LevelsGD")[0].enemy_spawn_ids[index]
	return 0

func onToolPickedUp(action: OccupyAction) -> void:
	onClear()
	var Tool: ToolGD = SavedData.onLoadModel(Helper.getFofInfoID(ToolInfo, spawn_id).saved_data.new(spawn_id, true), action.Card)
	onPushAction(AddToolAction.new(action.Card, Tool))
	

func onSave() -> SavedDataSpawn:
	return SavedDataSpawn.new(info.id, false, public_id, coords, tile_rotation, vision_datastore, variation, map_rotation, map_position, height,\
	occupied_tiles.map(func(x: TileGD): return x.getCoords()), spawn_id)

func onLoadDataLevel() -> void:
	super()
	Model.visible = false
	loaded_in_level = true

func isSpawnOccupied() -> bool:
	return occupied_tiles.any(func(x: TileGD): return x.isOccupied())
	
func getTile() -> TileGD:
	return occupied_tiles[0]

func setOccupiedTiles(tile_position_to_tile: Dictionary) -> void:
	super(tile_position_to_tile)

func setCollisionLayers(layer: int) -> void:
	if loaded_in_level: super(0)
	else: super(layer)
	
