class_name OverworldLevelGD extends LevelGD

#region Save / Load
func onSave() -> SavedData:
	return SavedDataOverworldLevel.new(info.id)

func onLoadData(data: SavedData) -> void:
	super(data)
	add_to_group("OverworldLevelsGD")
#endregion
