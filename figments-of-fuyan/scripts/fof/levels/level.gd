class_name LevelGD extends FofGD

var timeout: int
func onSave() -> SavedData:
	return SavedDataLevel.new(info.id)

func onClear() -> void:
	queue_free()

func onLoadData(data: SavedData) -> void:
	super(data)
	for light in info.lights:
		add_child(light.instantiate())
	
	for tile_object_data in info.data:
		var TileObject: TileObjectGD = SavedData.onLoadModel(tile_object_data, self)
		TileObject.add_to_group("LevelTileObjectsGD")
		if TileObject is TileGD: TileObject.add_to_group("LevelTilesGD")
		elif TileObject is ObjectGD: TileObject.add_to_group("LevelObjectsGD")
		
	for TileObject in get_tree().get_nodes_in_group("LevelTileObjectsGD"):
		TileObject.onLoadDataLevel()
		
	add_to_group("LevelsGD")

func onFofInit() -> void:
	var tile_position_to_tile: Dictionary
	for Tile in get_tree().get_nodes_in_group("TilesGD"):
		tile_position_to_tile[Tile.position] = Tile
	
	get_tree().call_group("ObjectsGD", "setOccupiedTiles", tile_position_to_tile)
	for TileObject in get_tree().get_nodes_in_group("LevelTileObjectsGD"):
		TileObject.onLevelFofInit()
