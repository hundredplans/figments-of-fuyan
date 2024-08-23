class_name TileInfoGD
extends TileObjectInfoGD

@export var tile_fill: PackedScene

func getBaseData() -> SavedDataTile: return SavedDataTile.new(id)
