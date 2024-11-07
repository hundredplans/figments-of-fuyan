class_name SpawnGD
extends ObjectGD
var loaded_in_level: bool = false
var spawn_id: int

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

func onSave() -> SavedDataSpawn:
	return SavedDataSpawn.new(info.id, false, public_id, coords, tile_rotation, level_visible, is_revealed, variation, map_rotation, map_position, height,\
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
	
