extends Node3D

#region Globals
var area_info: AreaInfoGD
var save_file: SaveFile
var UI: Control
@onready var WorldEnv: WorldEnvironment = %WorldEnvironment

var map_location: MapLocation
#endregion

#region Base Functions
func onLoad(_save_file: SaveFile) -> void:
	save_file = _save_file
	area_info = Helper.getResourcesRecursiveID(AreaInfoGD, save_file.map_location.area)
	map_location = save_file.map_location
	setEnvironment()
#endregion

#region Setters
func setEnvironment() -> void:
	WorldEnv.environment = area_info.base_environment if !map_location.isAfterMiniboss() else area_info.late_environment
