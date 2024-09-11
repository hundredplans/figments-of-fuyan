class_name LevelGD extends FofGD

var timeout: int
func onSave() -> SavedData:
	return SavedDataLevel.new(info.id)

func onClear() -> void:
	queue_free()

func onLoadData(data: SavedData) -> void:
	super(data)
	for tile_object_data in info.data:
		SavedData.onLoadModel(tile_object_data, self)
		
	for light in info.lights:
		add_child(light.instantiate())
	add_to_group("LevelsGD")
