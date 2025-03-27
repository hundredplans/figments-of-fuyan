class_name MinibossFightNodeGD extends EpicFightNodeGD

func onSave() -> SavedDataMapNode:
	return SavedDataMiniBossFight.new(info.id, false, public_id, map_location, links, is_entered, is_finished, rotation.y, ability_save, level_info, spawn_group, enemy_cards, boss_id)

func onLoadData(data: SavedData) -> void:
	super(data)

func onFinished() -> void:
	super()
