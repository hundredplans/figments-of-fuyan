class_name TraitInfo extends FofInfo

@export_group("Stat Replacement")
@export var icon: Texture2D
@export var replace_model: PackedScene
@export var replace_stat: Game.Stats
@export_group("")

@export var int_label_position: Vector2

@export_multiline var description: String

static func getFofName() -> String: return "Trait"
func getIcon() -> Texture2D: return icon
