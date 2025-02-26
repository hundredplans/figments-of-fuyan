class_name MinibossFightNodeGD extends FightNodeGD

var boss_id: int
func onSave() -> SavedDataMapNode:
	return SavedDataMiniBossFight.new(info.id, false, public_id, map_location, links, is_entered, is_finished, rotation.y, level_info, spawn_group, enemy_cards, boss_id)

func onLoadData(data: SavedData) -> void:
	super(data)
	boss_id = data.boss_id

func onFinished() -> void:
	super()
	var new_level_data: SavedDataLevel = level_info.saved_data.new(level_info.id, true, 0, level_info.data.duplicate())
	new_level_data.spawn_group = spawn_group
	new_level_data.enemy_cards = enemy_cards
	new_level_data.fight_type = Game.FightTypes.MINIBOSS
	
	load_level.emit(new_level_data)

func onFofInit() -> void:
	setLevelInfo()
	spawn_group = level_info.getRandomSpawnGroup()

func setLevelInfo() -> void:
	var id_to_id: IdToId = Game.getArea().info.miniboss_ids_to_level.pick_random()
	boss_id = id_to_id.id
	level_info = Helper.getFofInfoID(LevelInfo, id_to_id.foreign_id)

func getHoverUIPath() -> String:
	return info.EPIC_FIGHT_NODE_HOVER_UI
