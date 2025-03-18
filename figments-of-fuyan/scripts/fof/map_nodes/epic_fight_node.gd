class_name EpicFightNodeGD extends FightNodeGD

var boss_id: int
func onLoadData(data: SavedData) -> void:
	super(data)
	boss_id = data.boss_id

func onFofInit() -> void:
	setLevelInfo()
	spawn_group = level_info.getRandomSpawnGroup()

func onFinished() -> void:
	super()
	var new_level_data: SavedDataLevel = level_info.saved_data.new(level_info.id, true, 0, level_info.data.duplicate())
	new_level_data.spawn_group = spawn_group
	new_level_data.enemy_cards = enemy_cards
	new_level_data.fight_type = getFightType()
	
	load_level.emit(new_level_data)
	
func setLevelInfo() -> void:
	var fight_type: Game.FightTypes = getFightType()
	var epic_datastore: EpicAreaDatastore = Game.getArea().info.epic_datastores\
		.filter(func(x: EpicAreaDatastore): return x.type == fight_type).pick_random()
	
	boss_id = epic_datastore.epic_id
	level_info = Helper.getFofInfoID(LevelInfo, epic_datastore.level_id)

func getFightType() -> Game.FightTypes:
	return Game.FightTypes.MINIBOSS if (self is MinibossFightNodeGD) else Game.FightTypes.BOSS

func getHoverUIPath() -> String:
	return info.EPIC_FIGHT_NODE_HOVER_UI
