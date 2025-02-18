class_name BossFightNodeGD extends EliteFightNodeGD

func onSave() -> SavedDataMapNode:
	return SavedDataBossFight.new(info.id, false, public_id, map_location, links, is_entered, is_finished, rotation.y, level_info, spawn_group, enemy_cards, curse_id)

func onFinished() -> void:
	super()
	var new_level_data: SavedDataLevel = level_info.saved_data.new(level_info.id, true, 0, level_info.data.duplicate())
	new_level_data.spawn_group = spawn_group
	new_level_data.enemy_cards = enemy_cards
	new_level_data.curse_id = curse_id
	
	new_level_data.fight_type = Game.FightTypes.BOSS
	load_level.emit(new_level_data)
