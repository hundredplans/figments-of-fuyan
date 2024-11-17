class_name ToolInfo extends FofInfo

@export var icon: Image
@export_multiline var description: String
@export_multiline var ascended_description: String
@export var rarity: Game.Rarities
@export var active_abilities: Array[ActiveAbilityDatastore]
@export var model: PackedScene

static func getFofName() -> String: return "Tool"

static func getInfoPath() -> String: return "res://resources/fof/tools"
"res://resources/fof/tools/halfeaten_coconut.tres"
