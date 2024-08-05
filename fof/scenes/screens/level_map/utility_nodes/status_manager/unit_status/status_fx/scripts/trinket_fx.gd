extends StatusFXGD

func getTooltip() -> String:
	return AppliedBy.Applier.getDescription()

func getIcon() -> Texture2D:
	var trinket_info: Resource = preload("res://scenes/screens/level_map/utility_nodes/object_manager/extras/trinkets/trinket_info.tres")
	return trinket_info.getIcon(AppliedBy.Applier.trinket_id)
