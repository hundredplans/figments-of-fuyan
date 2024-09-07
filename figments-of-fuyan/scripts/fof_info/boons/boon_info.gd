@tool
class_name BoonInfo extends FofInfo

@export var icon: Texture2D
@export_multiline var description: String
@export var RARITY: Game.Rarities

static func getFofName() -> String: return "Boon"

static func getInfoPath() -> String: return "res://resources/fof/boons"

func getIcon() -> Texture2D:
	return icon

func getFancyIconText() -> String:
	return "[boon=" + str(id) + "]"
