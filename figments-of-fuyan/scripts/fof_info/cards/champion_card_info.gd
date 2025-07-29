class_name ChampionCardInfo extends CardInfo

@export_multiline var champion_upgrade_description: Array[String]
@export_group("Champion Select")
@export_multiline var champion_description: Array[String]
@export_color_no_alpha var associated_color: Color
@export var epithet: String
@export var champion_select_posrot: PosRot
@export_group("")

@export_group("Unique Nodes")
@export var unique_nodes_id: Array[int]

@export_group("Champion Boon")
@export var boon_info: BoonInfo
@export_group("")

static func getFofName() -> String: return "ChampionCard"
func getChampionUpgradeDescription(tier: int = 2) -> String:
	return champion_upgrade_description[tier - 2]
