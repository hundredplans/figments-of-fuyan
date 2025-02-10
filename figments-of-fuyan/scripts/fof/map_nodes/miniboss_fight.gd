class_name MinibossFightNodeGD extends EliteFightNodeGD

func onSave() -> SavedDataMapNode:
	return SavedDataMiniBossFight.new(info.id, false, public_id, map_location, links, is_entered, is_finished, rotation.y, level_info, enemy_spawns)

func onFinished() -> void:
	super()
	var new_level_data: SavedDataLevel = level_info.saved_data.new(level_info.id, true, 0, level_info.data.duplicate(), enemy_spawns)
	new_level_data.fight_type = Game.FightTypes.MINIBOSS
	load_level.emit(new_level_data)
