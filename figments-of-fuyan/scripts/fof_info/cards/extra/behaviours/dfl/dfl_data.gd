class_name DFLData extends Resource

var tiles_to_value: Dictionary
var KillTile: TileGD

func _init(_tiles_to_value: Dictionary = {}, _KillTile: TileGD = null) -> void:
	tiles_to_value = _tiles_to_value
	KillTile = _KillTile
