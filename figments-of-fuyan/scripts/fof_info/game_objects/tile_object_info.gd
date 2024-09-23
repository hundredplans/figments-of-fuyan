class_name TileObjectInfo extends GameObjectInfo

const GREYSCALE_MATERIAL: String = "res://resources/materials/game/base_material_greyscale_specular.tres"
@export var models: Array[PackedScene]
@export var points: Array[Array]

func getModel(variation: int) -> PackedScene:
	return models[variation]
