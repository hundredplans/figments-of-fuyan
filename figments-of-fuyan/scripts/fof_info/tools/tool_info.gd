class_name ToolInfo extends FofInfo

@export var tiers: Array[ToolTierDatastore]
@export var icon: Texture2D
@export var rarity: Game.Rarities

@export_group("Charges")
@export var use_charges: bool
@export var auto_reset_charges: bool
@export var reset_to_default: bool # Otherwise resets to 0
@export_group("")

@export_group("Remove")
@export var active_abilities: Array[ActiveAbilityDatastore]
@export_multiline var description: String
@export_multiline var ascended_description: String
@export_group("")

static func getFofName() -> String: return "Tool"

static func getInfoPath() -> String: return "res://resources/fof/tools"
"res://resources/fof/tools/halfeaten_coconut.tres"

func getIcon() -> Texture2D: return icon
func getDescription(tier: int = 1, use_default_values: bool = false) -> String:
	return getTierDatastore(tier).getDescription(use_default_values)
	
func getTierDatastore(tier: int = 1) -> ToolTierDatastore:
	tier -= 1
	return tiers[tier] if tiers.size() > tier else ToolTierDatastore.new()
