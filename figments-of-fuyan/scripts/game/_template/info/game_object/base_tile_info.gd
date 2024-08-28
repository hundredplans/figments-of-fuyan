class_name BaseTileInfoGD extends TileInfoGD

@export var overworld_tile: PackedScene

func getModel(variation: int) -> PackedScene:
	if variation == -1: return overworld_tile
	return models[variation]
