class_name BoonGD
extends Node

var GameEffects: GameEffectsGD
var Units: UnitsGD
var LevelUI: LevelUIGD
var LevelMap: LevelMapGD
var Hand: HandGD

var boon_info: BoonInfoGD
var is_ascended: bool = false

func setInfo(_boon_info: BoonInfoGD, _is_ascended: bool = false) -> void:
	boon_info = _boon_info
	is_ascended = _is_ascended
	Helper.onCreateChildReferences(self)

func getDescription() -> String:
	if !is_ascended: return boon_info.description
	else: return boon_info.ascended_description
