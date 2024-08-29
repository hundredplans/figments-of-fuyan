class_name PalmLevelInfo extends LevelInfo

@export var fake_coconuts: int = 0
#region Setting Values
func setPreviousLevelInfoValues(level_info: LevelInfo) -> void:
	super(level_info)
	fake_coconuts = level_info.fake_coconuts
#endregion
