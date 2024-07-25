class_name UniqueTileGD
extends Node

var Units: UnitsGD
var Combat: CombatGD
var Tiles: TilesGD
var GameEffects: GameEffectsGD
var ActionManager: ActionManagerGD
var Tools: ToolsGD

var info: UniqueTileInfoGD
var Tile: TileGD

func setInfo(_Tile: TileGD = null) -> void:
	Tile = _Tile
	Helper.onCreateChildReferences(self)
