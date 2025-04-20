class_name BossFightNodeGD extends EpicFightNodeGD

func onSave() -> SavedDataMapNode:
	return SavedDataBossFight.new(info.id, false, public_id, map_location, links, is_entered, is_finished, rotation.y, ability_save, level_info,\
		spawn_group, enemy_cards, level_rewards, boss_id)

func onLoadData(data: SavedData) -> void:
	super(data)

func onFinished() -> void:
	super()
