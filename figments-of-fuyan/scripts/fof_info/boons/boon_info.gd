class_name BoonInfo extends FofInfo

@export var tiers: Array[BoonTierDatastore]
@export var icon: Texture2D
@export var rarity: Game.Rarities
@export var curse: bool
@export var elite_fight_curse: bool
@export var display_trigger: bool = true

@export_group("Charges")
@export var use_charges: bool
@export var auto_reset_charges: bool
@export var reset_to_default: bool # Otherwise resets to 0
@export_group("")

@export_group("Remove")
@export_multiline var description: String
@export_multiline var ascended_description: String
@export_group("")

static func getFofName() -> String: return "Boon"

static func getInfoPath() -> String: return "res://resources/fof/boons"

func getIcon() -> Texture2D: return icon

func getDescription(tier: int = 1, use_default_values: bool = false) -> String:
	return getTierDatastore(tier).getDescription(use_default_values)
	
func getTierDatastore(tier: int = 1) -> BoonTierDatastore:
	tier -= 1
	return tiers[tier] if tiers.size() > tier else BoonTierDatastore.new()
