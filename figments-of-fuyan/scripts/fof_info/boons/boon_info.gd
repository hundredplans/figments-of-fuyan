class_name BoonInfo extends FofInfo

@export var icon: Texture2D
@export_multiline var description: String
@export_multiline var ascended_description: String
@export var rarity: Game.Rarities
@export var curse: bool
@export var elite_fight_curse: bool

@export_group("Charges")
@export var use_charges: bool
@export var auto_reset_charges_level_start: bool
@export var reset_to_default: bool # Otherwise resets to 0
@export_group("")

static func getFofName() -> String: return "Boon"

static func getInfoPath() -> String: return "res://resources/fof/boons"

func getIcon() -> Texture2D: return icon
func getDescription(ascended: bool = false) -> String:
	return description if !ascended else (ascended_description if !ascended_description.is_empty() else description)
