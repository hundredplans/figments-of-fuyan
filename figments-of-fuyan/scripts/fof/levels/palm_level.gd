class_name PalmLevelGD extends RegularLevelGD

func onGenerateBackground() -> void:
	var occupied_coords: Array = get_tree().get_nodes_in_group("TilesGD").map(func(x: TileGD): return x.getCoordsHeightless())
	const MAX_LEVEL_SIZE: int = 30
	for x in range(-MAX_LEVEL_SIZE, (MAX_LEVEL_SIZE + 1)):
		for y in range(max(-MAX_LEVEL_SIZE, -x - MAX_LEVEL_SIZE), min(MAX_LEVEL_SIZE, -x + MAX_LEVEL_SIZE) + 1):
			var _coords := Vector3i(x, y, -x-y)
			if _coords not in occupied_coords:
				var coords := Vector4i(x, y, -x-y, 0)
				var WaterTile := SavedData.onLoadModel(SavedDataTile.new(8, true, coords), self)
