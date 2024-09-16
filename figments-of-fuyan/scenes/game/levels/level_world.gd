extends Node3D

var level: LevelGD
var save_file: SaveFileGD
var area: AreaGD
var UI: Control

func setInfo(_save_file: SaveFileGD) -> void:
	save_file = _save_file
	area = save_file.area
	level = area.active_level
	level.onGenerateBackground()
