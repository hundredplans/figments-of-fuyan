class_name SpawnGD
extends ObjectGD

func onLoadData(data: SavedData) -> void:
	super(data)
	if variation == 0: add_to_group("AllySpawnsGD")

func onLoadDataLevel() -> void:
	super()
	Model.visible = false

func setLevelVisible(_state: bool, avoid_recursion: bool = false) -> void:
	super(true, avoid_recursion)

func isSpawnOccupied() -> bool:
	return occupied_tiles.any(func(x: TileGD): return x.isOccupied())
	
