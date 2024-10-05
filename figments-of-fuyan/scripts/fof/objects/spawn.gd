class_name SpawnGD
extends ObjectGD
var loaded_in_level: bool = false

func onLoadData(data: SavedData) -> void:
	super(data)
	add_to_group("SpawnsGD")
	match variation:
		0: add_to_group("AllySpawnsGD")
		1: add_to_group("EnemySpawnsGD")
		2: add_to_group("NeutralSpawnsGD")

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
	
