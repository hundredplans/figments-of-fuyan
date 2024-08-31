extends Control

#region Globals
var World: Node3D
var save_file: SaveFileGD
var area: AreaGD
#endregion

#region Base Functions
func onLoad(_save_file: SaveFileGD) -> void:
	save_file = _save_file
	area = save_file.area
#endregion
