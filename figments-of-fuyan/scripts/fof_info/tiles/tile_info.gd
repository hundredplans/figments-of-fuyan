class_name TileInfo extends TileObjectInfo

const FALL_DAMAGE_EFFECT_SCENE_PATH: String = "res://scenes/game/tiles/fall_damage_effect.tscn"
const PATH_HOVERED_MATERIAL: String = "res://resources/materials/colors/unshaded/grey.tres"
const MOVEMENT_RANGE_ATTACKABLE_MATERIAL: String = "res://resources/materials/colors/unshaded/pink.tres"
const MOVEMENT_RANGE_MATERIAL: String = "res://resources/materials/colors/unshaded/light_grey.tres"
const HOVERED_MATERIAL: String = "res://resources/materials/colors/unshaded/white.tres"
const ALLY_OCCUPY_MATERIAL: String = "res://resources/materials/colors/unshaded/green.tres"
const ENEMY_OCCUPY_MATERIAL: String = "res://resources/materials/colors/unshaded/red.tres"
const NEUTRAL_OCCUPY_MATERIAL: String = "res://resources/materials/colors/unshaded/brown.tres"
const ACTIVE_EFFECT_RANGE_MATERIAL: String = "res://resources/materials/colors/unshaded/orange.tres"
const ACTIVE_EFFECT_PICKABLE_MATERIAL: String = "res://resources/materials/colors/unshaded/pink.tres"

const LIGHTER_RED_TILE_INTENT_MODEL_PATH: String = "res://assets/models/general/tile_intents/lighter_red_tile_intent"
const RED_TILE_INTENT_MODEL_PATH: String = "res://assets/models/general/tile_intents/red_tile_intent"
const GREEN_TILE_INTENT_MODEL_PATH: String = "res://assets/models/general/tile_intents/green_tile_intent"
const DARK_RED_TILE_INTENT_MODEL_PATH: String = "res://assets/models/general/tile_intents/dark_red_tile_intent"
const PURPLE_TILE_INTENT_MODEL_PATH: String = "res://assets/models/general/tile_intents/purple_tile_intent"
const LIGHT_RED_TILE_INTENT_MODEL_PATH: String = "res://assets/models/general/tile_intents/light_red_tile_intent"
const YELLOW_TILE_INTENT_MODEL_PATH: String = "res://assets/models/general/tile_intents/yellow_tile_intent"

@export var tile_fill: PackedScene
@export var decoration_models: Array[PackedScene]
@export var tile_height: float = 0.3

static func getInfoPath() -> String: return "res://resources/fof/tile_objects"
func getModel(variation: int, is_decoration: bool = false) -> PackedScene:
	return models[variation] if !is_decoration else decoration_models[variation]
	
static func getFofName() -> String: return "Tile"

func getTileIntentModelPath(tile_intent: Game.TileIntents, variation: int = 0) -> String:
	var path: String = ""
	match tile_intent:
		Game.TileIntents.RED: path = RED_TILE_INTENT_MODEL_PATH
		Game.TileIntents.GREEN: path = GREEN_TILE_INTENT_MODEL_PATH
		Game.TileIntents.DARK_RED: path = DARK_RED_TILE_INTENT_MODEL_PATH
		Game.TileIntents.PURPLE: path = PURPLE_TILE_INTENT_MODEL_PATH
		Game.TileIntents.LIGHT_RED: path = LIGHT_RED_TILE_INTENT_MODEL_PATH
		Game.TileIntents.LIGHTER_RED: path = LIGHTER_RED_TILE_INTENT_MODEL_PATH
		Game.TileIntents.YELLOW: path = YELLOW_TILE_INTENT_MODEL_PATH
	
	if variation == 1:
		path += "_stair"
	
	path += ".glb"
	return path
