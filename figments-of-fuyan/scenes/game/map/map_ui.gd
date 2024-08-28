extends Control

#region Globals
var World: Node3D
var save_file: SaveFile
#endregion

#region Base Functions
func onLoad(_save_file: SaveFile) -> void:
	save_file = _save_file
#endregion
