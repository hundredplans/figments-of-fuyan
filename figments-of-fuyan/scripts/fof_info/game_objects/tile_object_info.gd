class_name TileObjectInfo extends FofInfo

@export var models: Array[PackedScene]
@export var points: Array[Array]

func getModel(variation: int) -> PackedScene:
	return models[variation]
