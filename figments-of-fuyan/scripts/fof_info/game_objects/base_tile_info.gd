@tool
class_name BaseTileInfo extends TileInfo

@export var overworld_tile: PackedScene

func getModel(variation: int) -> PackedScene:
	if variation == -1: return overworld_tile
	return models[variation]
