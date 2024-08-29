@tool
class_name BoonInfo extends FofInfo

@export_multiline var description: String
@export var RARITY: RARITIES

enum RARITIES {SCRAP, MINI, COMMON, RARE, EXALT, MINIBOSS, BOSS, CHAMPION}


static func getInfoPath() -> String: return "res://resources/fof/boons/"
