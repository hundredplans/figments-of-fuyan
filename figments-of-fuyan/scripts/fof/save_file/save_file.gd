class_name SaveFileGD extends FofGD

var id: int
var my_seed: int
var area: AreaGD

#region Save / Load
func onSave() -> SavedData:
	return SavedDataSaveFile.new(id, my_seed, area.onSave())

func onLoadData(data: SavedData) -> void:
	super(data)
	id = data.id
	my_seed = data.my_seed
	add_to_group("SaveFilesGD")
#endregion
