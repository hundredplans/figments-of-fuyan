extends Node3D

#region Globals
var save_file: SaveFileGD
var area: AreaGD
var UI: Control
@onready var WorldEnv: WorldEnvironment = %WorldEnvironment
#endregion

#region Base Functions
func onLoad(_save_file: SaveFileGD) -> void:
	save_file = _save_file
	area = save_file.area
	setEnvironment()
#endregion

#region Setters
func setEnvironment() -> void:
	WorldEnv.environment = area.info.base_environment\
	if !area.map_location.isAfterMiniboss() else area.info.late_environment
#endregion
