extends Control

var save_file: SaveFileGD
var area: AreaGD
var World: Node3D

func setInfo(_save_file: SaveFileGD) -> void:
	save_file = _save_file
	area = save_file.area
