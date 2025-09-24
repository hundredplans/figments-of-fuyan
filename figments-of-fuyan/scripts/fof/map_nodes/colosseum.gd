extends EncounterGD

var SPECIAL_FIGHT_TYPES: Array = ["Mirror Fight", "Curse Fight", "Advanced Fight", "Foreign Fight"]
const CURSE_IDS: Array = [11, 12, 14, 15]

var chosen_special_fights: Array
var level_public_id: int
var level_info: LevelInfo

const ENTER_DELAY: float = 0.75

func onProcessAction(action: Action) -> void:
	super(action)
	if action.post:
		if action is LevelRewardsFinishedAction and action.getActiveLevelData().public_id == level_public_id:
			onFinished()

func onFofInit() -> void:
	super()
	
	var _special_fight_types: Array = SPECIAL_FIGHT_TYPES.duplicate()
	_special_fight_types.shuffle()
	chosen_special_fights = [_special_fight_types.pop_back(), _special_fight_types.pop_back()]

func onSave() -> SavedDataEncounter:
	ability_save['level_public_id'] = level_public_id
	ability_save['chosen_special_fights'] = chosen_special_fights
	return super()

func isDragZone() -> bool: return false
	
func onLoadLevel(level_data: SavedDataLevel, area_id: int = Game.getArea().getInfo().id) -> void:
	onPushAction([DelayAction.new(ENTER_DELAY), StartLoadingScreenAction.new(
		Game.LoadingType.LEVEL,
		area_id,
		Helper.getFofInfoID(LevelInfo, level_data.id).name,
		map_location.progress,
		level_data.curse_id
	), CreateLevelAction.new(level_data)])
	
func onCreateSpecialFight(is_right: bool) -> void:
	var progress: int = Game.getArea().getProgress()
	var special_fight_type: String = chosen_special_fights[int(is_right)]
	var valid_area_id: int = Game.getArea().getInfo().id
	if special_fight_type == "Foreign Fight":
		valid_area_id = Game.getSaveFile().VALID_AREA_IDS.filter(func(x: int): return x != valid_area_id).pick_random()
		var levels: Array = Helper.getFofInfoArray(LevelInfo)
		var budget: int = Game.getArea().getBudget(progress)
		var level_script: GDScript = Helper.getFofInfoID(AreaInfo, valid_area_id).base_level_script
		levels = levels.filter(func(x: LevelInfo): return x.gdscript == level_script)
		levels = levels.filter(func(x: LevelInfo): return budget >= x.budget_min and budget <= x.budget_max)
		level_info = levels.pick_random()
	else: level_info = Game.getArea().getLevelInfoForProgress(Game.getArea().getProgress())
	
	var spawn_group: int = level_info.getRandomSpawnGroup()
	var enemy_spawns: Array = level_info.getEnemySpawnsInGroup(spawn_group) # Array[SavedDataSpawn]
	enemy_spawns.shuffle()

	var level_data: SavedDataLevel
	match special_fight_type:
		"Mirror Fight": level_data = onCreateMirrorFight(enemy_spawns, spawn_group)
		"Curse Fight": level_data = onCreateCurseFight(enemy_spawns, spawn_group, progress)
		"Advanced Fight": level_data = onCreateAdvancedFight(enemy_spawns, spawn_group, progress)
		"Foreign Fight": level_data = onCreateForeignFight(enemy_spawns, spawn_group, progress, valid_area_id)
	assert(level_data != null)
	level_public_id = Game.onIncrementPublicID()
	level_data.public_id = level_public_id
	onLoadLevel(level_data, valid_area_id)
	
	
func onCreateAdvancedFight(enemy_spawns: Array, spawn_group: int, progress: int) -> SavedDataLevel:
	var budget: int = Game.getArea().getBudget(progress)
	var enemy_cards: Array = Game.getArea().setEnemySpawnsFromBudget(budget, enemy_spawns, progress)
	
	for card_data: SavedDataCard in enemy_cards:
		card_data.tier = min(card_data.tier + 1, Game.MAX_TIER)
		Game.setCardDataFromInfo(card_data, Helper.getFofInfoID(CardInfo, card_data.id))
		
		if card_data.tool_data != null:
			card_data.tool_data.tier = min(card_data.tool_data.tier + 1, Game.MAX_TIER)
	
	level_public_id = Game.onIncrementPublicID()
	var level_data: SavedDataLevel = level_info.saved_data.new(level_info.id, true, 0, level_info.data.duplicate())
	level_data.enemy_cards = enemy_cards
	level_data.spawn_group = spawn_group
	level_data.fight_type = Game.FightTypes.ADVANCED
	return level_data

func onCreateForeignFight(enemy_spawns: Array, spawn_group: int, progress: int, valid_area_id: int) -> SavedDataLevel:
	var budget: int = Game.getArea().getBudget(progress)
	var enemy_cards: Array = Game.getArea().setEnemySpawnsFromBudget(budget, enemy_spawns, progress, 0, valid_area_id)
	var level_preview: LevelPreview = Game.getArea().getLevelPreview(enemy_cards)
	var level_data: SavedDataLevel = level_info.saved_data.new(level_info.id, true, 0, level_info.data.duplicate())
	level_data.enemy_cards = enemy_cards
	level_data.spawn_group = spawn_group
	level_data.fight_type = Game.FightTypes.FOREIGN
	level_data.level_preview = level_preview
	return level_data
	
func onCreateCurseFight(enemy_spawns: Array, spawn_group: int, progress: int) -> SavedDataLevel:
	var valid_curse_ids: Array = []
	for _curse_id: int in CURSE_IDS:
		var curse_info: BoonInfo = Helper.getFofInfoID(BoonInfo, _curse_id)
		var Curse: BoonGD = SavedData.onLoadModel(curse_info.saved_data.new(curse_info.id, 0, true), self)
		if Curse.isAddRequirementMet(): valid_curse_ids.append(_curse_id)
		Curse.onClear()
		
	var curse_id: int = valid_curse_ids.pick_random()
	var budget: int = Game.getArea().getBudget(progress)
	var enemy_cards: Array = Game.getArea().setEnemySpawnsFromBudget(budget, enemy_spawns, progress)
	var level_data: SavedDataLevel = level_info.saved_data.new(level_info.id, true, 0, level_info.data.duplicate())
	level_data.enemy_cards = enemy_cards
	level_data.spawn_group = spawn_group
	level_data.fight_type = Game.FightTypes.CURSE
	level_data.curse_id = curse_id
	return level_data

func onCreateMirrorFight(enemy_spawns: Array, spawn_group: int) -> SavedDataLevel:
	var cards: Array = Game.getDeckCards()
	var spawn_amount: int = min(enemy_spawns.size(), Game.getSaveFile().getDeckSlots().size())
	cards.shuffle()
	cards.resize(spawn_amount)
	cards = cards.filter(func(x: CardGD): return x != null)
	
	var stash_cards: Array = get_tree().get_nodes_in_group("StashCardsGD")
	stash_cards.shuffle()
	for __: int in range(spawn_amount - cards.size()):
		if stash_cards.is_empty(): break
		cards.append(stash_cards.pop_back())
	
	var enemy_cards: Array = []
	for i: int in range(cards.size()):
		var Card: CardGD = cards[i]	
		var tool_data: SavedDataTool
		if Card.getTool() != null:
			var tool_info: ToolInfo = Card.getTool().info
			var tool_tier: int = Card.getTool().getTier()
			tool_data = tool_info.saved_data.new(tool_info.id, true)
			tool_data.tier = tool_tier
		var card_data: SavedDataCard = Game.onCreateBaseCard(Card.info.id, Card.getTier(), tool_data)
		card_data.coords = enemy_spawns[i].coords
		card_data.team = 1
		enemy_cards.append(card_data)
		
	var level_preview: LevelPreview = Game.getArea().getLevelPreview(enemy_cards)
	var level_data: SavedDataLevel = level_info.saved_data.new(level_info.id, true, 0, level_info.data.duplicate())
	level_data.enemy_cards = enemy_cards
	level_data.spawn_group = spawn_group
	level_data.fight_type = Game.FightTypes.MIRROR
	level_data.level_preview = level_preview
	return level_data

func getChosenSpecialFights() -> Array: return chosen_special_fights
