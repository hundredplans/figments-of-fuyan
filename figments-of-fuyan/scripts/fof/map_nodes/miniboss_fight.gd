class_name MinibossFightNodeGD extends FightNodeGD

func onSave() -> SavedDataMapNode:
	return SavedDataMiniBossFight.new(info.id, false, public_id, map_location, links, is_entered, is_finished, rotation.y, level_info, enemy_spawns)
