class_name TraitInfo extends FofInfo

@export_group("Stat Replacement")
@export var icon: Texture2D
@export var replace_model: PackedScene
@export var replace_stat: Game.Stats
@export_group("")

@export_multiline var description: String

static func getFofName() -> String: return "Trait"
