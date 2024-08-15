class_name PalmLevelInfoGD
extends LevelInfoGD

@export var fake_coconuts: int = 0
#region Setting Values
func setPreviousLevelInfoValues(level_info: LevelInfoGD) -> void:
	super(level_info)
	fake_coconuts = level_info.fake_coconuts
#endregion
