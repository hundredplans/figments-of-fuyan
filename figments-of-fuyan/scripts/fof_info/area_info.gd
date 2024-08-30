@tool
class_name AreaInfo extends FofInfo

@export var card_background: Image
@export var cards: Array[CardInfo]
@export var overworld: OverworldLevelInfo
@export var base_environment: Environment
@export var late_environment: Environment

static func getInfoPath() -> String: return "res://resources/fof/areas"
