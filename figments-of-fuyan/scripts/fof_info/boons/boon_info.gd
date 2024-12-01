class_name BoonInfo extends FofInfo

@export var icon: Texture2D
@export_multiline var description: String
@export_multiline var ascended_description: String
@export var rarity: Game.Rarities
@export var curse: bool

static func getFofName() -> String: return "Boon"

static func getInfoPath() -> String: return "res://resources/fof/boons"

func getTextIcon() -> Texture2D: return icon
