class_name FightNodeGD extends MapNodeGD

var spawn_group: int
var level_preview: LevelPreview
var enemy_cards: Array # Array[SavedDataCard]
var level_info: LevelInfo
var level_public_id: int

const ENTER_DELAY: float = 2.0

#region Save / Load / Init
func onFofInit() -> void:
	super()
	setLevelInfo()
	setLevelExtraData(getBudget())
	
func setLevelExtraData(budget: int) -> void:
	spawn_group = level_info.getRandomSpawnGroup()
	var enemy_spawns: Array = level_info.getEnemySpawnsInGroup(spawn_group) # Array[SavedDataSpawn]
	enemy_spawns.shuffle()
	
	enemy_cards = Game.getArea().setEnemySpawnsFromBudget(budget, enemy_spawns, map_location.progress, getEliteExaltId())
	onCreateLevelPreview(enemy_cards)
	
func onCreateLevelPreview(enemy_cards: Array) -> void:
	level_preview = Game.getArea().getLevelPreview(enemy_cards)
	
func getEliteExaltId() -> int: return 0
	
func onSave() -> SavedDataMapNode:
	return SavedDataFight.new(info.id, false, public_id, map_location, links, is_entered, is_finished, rotation.y, ability_save, level_info, spawn_group,\
		enemy_cards, level_preview, level_public_id)
	
func onLoadData(data: SavedData) -> void:
	super(data)
	level_info = data.level_info
	enemy_cards = data.enemy_cards
	spawn_group = data.spawn_group
	level_preview = data.level_preview
	level_public_id = data.level_public_id
	add_to_group("FightMapNodesGD")
#endregion

#region Hovering
func onUpdateHovered() -> void:
	if is_queued_for_deletion(): return
	var state: bool = getHoveredState()
	if state:
		if HoverUI != null: HoverUI.queue_free()
		HoverUI = load(getHoverUIPath()).instantiate()
	super()
	
func getHoverUIPath() -> String:
	return info.FIGHT_NODE_HOVER_UI
#endregion

#region Loading Level
func onEnteredInit() -> void:
	super()
	if self is EliteFightNodeGD or self is MinibossFightNodeGD or self is BossFightNodeGD: return
	var new_level_data: SavedDataLevel = level_info.saved_data.new(level_info.id, true, 0, level_info.data.duplicate())
	new_level_data.enemy_cards = enemy_cards
	new_level_data.level_preview = level_preview
	new_level_data.spawn_group = spawn_group
	new_level_data.fight_type = Game.FightTypes.REGULAR
	level_public_id = Game.onIncrementPublicID()
	new_level_data.public_id = level_public_id
	onPushLoadingScreenAction(new_level_data)
		
func onPushLoadingScreenAction(level_data: SavedDataLevel, area_id: int = Game.getArea().getInfo().id) -> void:
	var delay_action := DelayAction.new(ENTER_DELAY)
	onPushAction([delay_action, StartLoadingScreenAction.new(
		Game.LoadingType.LEVEL,
		area_id,
		Helper.getFofInfoID(LevelInfo, level_data.id).name,
		Game.getArea().getProgress(),
		level_data.curse_id
	), CreateLevelAction.new(level_data)])
#endregion

#region Level Gen
func getBudget() -> int:
	return Game.area.getBudget(map_location.progress, 0)
	
func setLevelInfo() -> void:
	if Helper.admin_datastore.force_level_spawn_id > 0 and map_location.progress == 1:
		level_info = Helper.getFofInfoID(LevelInfo, Helper.admin_datastore.force_level_spawn_id)
	else:
		level_info = Game.getArea().getLevelInfoForProgress(map_location.progress)
#endregion

func onProcessAction(action: Action) -> void:
	super(action)
	if action.post:
		if action is LevelRewardsFinishedAction and action.getActiveLevelData().public_id == level_public_id:
			onFinished()
