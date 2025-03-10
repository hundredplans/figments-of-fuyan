class_name ToolInfo extends FofInfo

@export var icon: Texture2D
@export_multiline var description: String
@export_multiline var ascended_description: String
@export var rarity: Game.Rarities
@export var active_abilities: Array[ActiveAbilityDatastore]
@export var model: PackedScene

@export_group("Charges")
@export var use_charges: bool
@export var auto_reset_charges: bool
@export var reset_to_default: bool # Otherwise resets to 0
@export_group("")

static func getFofName() -> String: return "Tool"

static func getInfoPath() -> String: return "res://resources/fof/tools"
"res://resources/fof/tools/halfeaten_coconut.tres"

func getIcon() -> Texture2D: return icon
func getDescription(ascended: bool = false) -> String:
	return description if !ascended else (ascended_description if !ascended_description.is_empty() else description)
