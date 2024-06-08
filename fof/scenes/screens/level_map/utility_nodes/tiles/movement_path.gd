class_name MovementPathGD
extends Resource

var OriginTile: TileGD
var DestinationTile: TileGD
var fneighbours: Array # Array of fneighbour, fall dmg
var fall_damages: Dictionary # Dictionary that associates each tile to a specific fall dmg

func _init(_Tile: TileGD) -> void:
	OriginTile = _Tile
