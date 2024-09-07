class_name ChampionBoonInfo extends BoonInfo

@export var champion_id: int
func getIcon() -> Texture2D:
	return Helper.getResourcesRecursiveID(CardInfo, champion_id).getIcon()
