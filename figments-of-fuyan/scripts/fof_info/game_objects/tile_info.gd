class_name TileInfo extends TileObjectInfo

const FALL_DAMAGE_EFFECT_SCENE_PATH: String = "res://scenes/game/tiles/fall_damage_effect.tscn"
const PATH_HOVERED_MATERIAL: String = "res://resources/materials/colors/unshaded/grey.tres"
const MOVEMENT_RANGE_ATTACKABLE_MATERIAL: String = "res://resources/materials/colors/unshaded/pink.tres"
const MOVEMENT_RANGE_MATERIAL: String = "res://resources/materials/colors/unshaded/light_grey.tres"
const HOVERED_MATERIAL: String = "res://resources/materials/colors/unshaded/white.tres"
const ALLY_OCCUPY_MATERIAL: String = "res://resources/materials/colors/unshaded/green.tres"
const ENEMY_OCCUPY_MATERIAL: String = "res://resources/materials/colors/unshaded/red.tres"
const NEUTRAL_OCCUPY_MATERIAL: String = "res://resources/materials/colors/unshaded/brown.tres"
@export var tile_fill: PackedScene

static func getInfoPath() -> String: return "res://resources/fof/tile_objects"
