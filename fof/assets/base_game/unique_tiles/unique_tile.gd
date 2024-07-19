class_name UniqueTileGD
extends Node

var info: UniqueTileInfoGD
var Tile: TileGD

func setInfo(_Tile: TileGD = null) -> void:
	Tile = _Tile
	Helper.onCreateChildReferences(self)
