class_name SavedDataOverworldLevel extends SavedDataLevel

func _init(_id: int = 0) -> void:
	super(_id)

func getInfoType() -> GDScript: return OverworldLevelInfo
