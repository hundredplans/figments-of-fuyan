class_name BoonInfo extends FofInfo

@export var icon: Image
@export_multiline var description: String
@export var RARITY: Game.Rarities

static func getFofName() -> String: return "Boon"

static func getInfoPath() -> String: return "res://resources/fof/boons"
