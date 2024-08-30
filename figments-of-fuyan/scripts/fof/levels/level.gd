class_name LevelGD extends FofGD

var timeout: int
func onSave() -> SavedData:
	return SavedDataLevel.new(info.id)

func onClear() -> void:
	queue_free()

func onLoadData(data: SavedData) -> void:
	super(data)
	add_to_group("LevelGD")
