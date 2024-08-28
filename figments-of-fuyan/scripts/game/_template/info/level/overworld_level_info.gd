class_name OverworldLevelInfoGD extends LevelInfoGD

func getBaseData() -> SavedDataLevel:
	return SavedDataOverworldLevel.new(id)

func setInfo(_name: String = "", _area_id: int = 1, _data: Array[SavedData] = [], _id: int = 0) -> void:
	super(_name, _area_id, _data, _id)
