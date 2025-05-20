class_name TileObjectInfo extends GameObjectInfo

const GREYSCALE_MATERIAL: String = "res://resources/materials/game/base_material_greyscale_specular.tres"
@export var area_ids: Array[int] # Which areas this Tile Object associates with (comes at the top of search)

static func getFofName() -> String: return "TileObject"
