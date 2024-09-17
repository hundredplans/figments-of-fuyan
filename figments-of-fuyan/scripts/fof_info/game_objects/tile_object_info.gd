class_name TileObjectInfo extends GameObjectInfo

@export var models: Array[PackedScene]
@export var points: Array[Array]

func getModel(variation: int) -> PackedScene:
	return models[variation]
