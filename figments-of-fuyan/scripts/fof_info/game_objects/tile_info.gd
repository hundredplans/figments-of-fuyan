class_name TileInfo extends TileObjectInfo

const HOVERED_MATERIAL: String = "res://resources/materials/colors/unshaded/white.tres"
const ALLY_OCCUPY_MATERIAL: String = "res://resources/materials/colors/unshaded/green.tres"
const ENEMY_OCCUPY_MATERIAL: String = "res://resources/materials/colors/unshaded/red.tres"
const NEUTRAL_OCCUPY_MATERIAL: String = "res://resources/materials/colors/unshaded/brown.tres"
@export var tile_fill: PackedScene

static func getInfoPath() -> String: return "res://resources/fof/tile_objects"
