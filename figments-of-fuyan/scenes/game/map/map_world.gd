extends Node3D

#region Globals
var save_file: SaveFile
var overworld_level: OverworldLevelGD
var UI: Control
@onready var WorldEnv: WorldEnvironment = %WorldEnvironment
#endregion

#region Base Functions
func onLoad(_save_file: SaveFile, Unit: UnitGD) -> void:
	save_file = _save_file
	overworld_level = save_file.overworld_level_data.onLoadModel(self)
	overworld_level.onGenerateBaseMapNodes(Unit)
	setEnvironment()
#endregion

#region Setters
func setEnvironment() -> void:
	WorldEnv.environment = overworld_level.area_info.base_environment\
	if !overworld_level.map_location.isAfterMiniboss() else overworld_level.area_info.late_environment
#endregion
